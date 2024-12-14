import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/brand/screen/brand_screen.dart';
import 'package:sanitary_mart/category/provider/category_provider.dart';
import 'package:sanitary_mart/core/constant/constant.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/list_item_widget.dart';
import 'package:sanitary_mart/core/widget/search_text_field.widget.dart';
import 'package:sanitary_mart/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart/core/widget/view_type_toggle.dart';
import 'package:sanitary_mart/core/widget/widget.dart';
import 'package:sanitary_mart/product/model/product_model.dart';
import 'package:sanitary_mart/product/ui/screen/product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = AppConst.isGridDefaultView;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String searchQuery='';
  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty && searchQuery!=_searchController.text) {
      searchQuery = _searchController.text;
      Provider.of<CategoryProvider>(context, listen: false)
          .filterProduct(_searchController.text);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void fetchCategories() {
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
  }

  void _toggleView() {
    if (mounted) {
      setState(() {
        _isGridView = !_isGridView;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Categories',
        actions: [
          ViewTypeToggle(
            onToggle: (isGridView) {
              _isGridView = isGridView;
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomSearchTextField(
                controller: _searchController,
                hintText: 'Search Product',
              ),
            ),
          ),
          _searchController.text.isNotEmpty
              ? Consumer<CategoryProvider>(
                  builder: (context, provider, child) {
                    if (provider.state == ProviderState.loading) {
                      return SliverFillRemaining(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ShimmerGridListWidget(
                          isGridView: _isGridView,
                        ),
                      ));
                    } else if (provider.state == ProviderState.error) {
                      return SliverFillRemaining(
                        child: ErrorRetryWidget(
                          onRetry: () {
                            if (_searchController.text.isNotEmpty) {
                              _onSearchChanged();
                            } else {
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          },
                        ),
                      );
                    }

                    if (provider.filteredProductList.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text('No product available'),
                        ),
                      );
                    }

                    return _buildProductListView(provider);
                  },
                )
              : Consumer<CategoryProvider>(
                  builder: (context, provider, child) {
                    if (provider.state == ProviderState.loading) {
                      return SliverFillRemaining(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ShimmerGridListWidget(
                          isGridView: _isGridView,
                        ),
                      ));
                    } else if (provider.state == ProviderState.error) {
                      return SliverFillRemaining(
                        child: ErrorRetryWidget(
                          onRetry: () {
                            fetchCategories();
                          },
                        ),
                      );
                    }

                    if (provider.filteredCategoryList.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text('No category available'),
                        ),
                      );
                    }

                    return _isGridView
                        ? _buildGridView(provider)
                        : _buildListView(provider);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildGridView(CategoryProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final category = provider.filteredCategoryList[index];
            return GridItemWidget(
              name: category.name,
              image: category.imagePath ?? '',
              onItemTap: () {
                Get.to(BrandScreen(category.id!));
              },
            );
          },
          childCount: provider.filteredCategoryList.length,
        ),
      ),
    );
  }

  Widget _buildListView(CategoryProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final category = provider.filteredCategoryList[index];
          return ListItemWidget(
            name: category.name,
            image: category.imagePath ?? '',
            onItemTap: () {
              Get.to(BrandScreen(category.id!));
            },
          );
        },
        childCount: provider.filteredCategoryList.length,
      ),
    );
  }

  Widget _buildProductListView(CategoryProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final Product product = provider.filteredProductList[index];
          return ListItemWidget(
            name: product.name,
            image: product.image ?? '',
            price: product.price.toString(),
            onItemTap: () async {
              // _searchController.clear();
              String? brandName = await provider.fetchBrand(product.brandId);
              Get.to(ProductDetailPage(
                  product: product, brandName: brandName ?? ''));
            },
          );
        },
        childCount: provider.filteredProductList.length,
      ),
    );
  }
}
