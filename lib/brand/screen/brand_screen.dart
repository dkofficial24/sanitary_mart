import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/brand/provider/brand_provider.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/search_text_field.widget.dart';
import 'package:sanitary_mart/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart/core/widget/widget.dart';
import 'package:sanitary_mart/product/ui/screen/product_list_screen.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen(this.categoryId, {super.key});

  final String categoryId;

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchBrandsByCategory();
    });
    super.initState();
  }

  void fetchBrandsByCategory() {
    Provider.of<BrandProvider>(
      context,
      listen: false,
    ).getBrandsByCategory(
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Brands',
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchTextField(
                controller: _searchController,
                hintText: 'Search Brand',
              ),
            ),
          ),
          Consumer<BrandProvider>(
            builder: (context, provider, child) {
              if (provider.state == ProviderState.loading) {
                return const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerGridListWidget(),
                    )
                );
              } else if (provider.state == ProviderState.error) {
                return SliverFillRemaining(
                  child: ErrorRetryWidget(
                    onRetry: () {
                      fetchBrandsByCategory();
                    },
                  ),
                );
              }

              if (provider.filteredBrandList.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No brands available for this category'),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final brand = provider.filteredBrandList[index];
                      return GridItemWidget(
                        name: brand.name,
                        image: brand.imagePath ?? '',
                        onItemTap: () {
                          Get.off(ProductListScreen(
                            categoryId: widget.categoryId,
                            brandId: brand.id!,
                            brandName: brand.name,
                          ));
                        },
                      );
                    },
                    childCount: provider.filteredBrandList.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<BrandProvider>(context, listen: false)
        .filterBrands(_searchController.text);
  }
}
