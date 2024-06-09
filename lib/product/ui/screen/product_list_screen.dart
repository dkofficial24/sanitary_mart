import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/search_text_field.widget.dart';
import 'package:sanitary_mart/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart/core/widget/widget.dart';
import 'package:sanitary_mart/product/model/product_model.dart';
import 'package:sanitary_mart/product/provider/product_provider.dart';
import 'package:sanitary_mart/product/ui/screen/product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    required this.categoryId,
    required this.brandId,
    required this.brandName,
    Key? key,
  }) : super(key: key);

  final String categoryId;
  final String brandId;
  final String brandName;

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchAllProducts();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<ProductProvider>(context, listen: false)
        .searchProducts(_searchController.text);
  }

  void fetchAllProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchAllProducts(
      widget.categoryId,
      widget.brandId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.brandName,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchTextField(
                controller: _searchController,
                hintText: 'Search Products',
              ),
            ),
          ),
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.state == ProviderState.loading) {
                return const SliverFillRemaining(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerGridListWidget(),
                  ),
                );
              } else if (provider.state == ProviderState.error) {
                return SliverFillRemaining(
                  child: ErrorRetryWidget(
                    onRetry: () {
                      fetchAllProducts();
                    },
                  ),
                );
              }

              if (provider.filteredProducts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No products available under this brand'),
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
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      final Product product = provider.filteredProducts[index];
                      return InkWell(
                        onTap: () {
                          Get.to(ProductDetailPage(
                            product: product,
                            brandName: widget.brandName,
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: NetworkImageWidget(
                                    product.image ?? '',
                                     imgHeight: 50,
                                  ),
                                ),
                                height: 100,width: 100,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: provider.filteredProducts.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
