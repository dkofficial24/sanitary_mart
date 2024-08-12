import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/provider/auth_provider.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/cart/ui/screen/cart_screen.dart';
import 'package:sanitary_mart/core/constant/constant.dart';
import 'package:sanitary_mart/core/debouncer.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/list_item_widget.dart';
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
  bool _isGridView = AppConst.isGridDefaultView;

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

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.brandName,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAnalytics.instance.logEvent(name: 'pdp_cart');
                Get.to(() => const CartScreen());
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ))
          // ViewTypeToggle(
          //   onToggle: (isGridView) {
          //     _isGridView = isGridView;
          //     setState(() {});
          //   },
          // ),
        ],
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
                return SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ShimmerGridListWidget(isGridView: _isGridView),
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

              return _isGridView
                  ? _buildGridView(provider)
                  : _buildListView(provider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ProductProvider provider) {
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
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: NetworkImageWidget(
                          product.image ?? '',
                          imgHeight: 50,
                        ),
                      ),
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
  }

  Widget _buildListView(ProductProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final cartProvider =
              Provider.of<CartProvider>(context, listen: false);
          String? uid = getUserId();
          final Product product = provider.filteredProducts[index];
          return ListItemWidget(
            id: product.id,
            name: product.name,
            image: product.image ?? '',
            price: product.price.toString(),
            onQuantityChange: (value) {},
            onAdd: (value) {
              DeBouncer.run(() {
                cartProvider.addAndUpdateCart(
                    uid!, product, value, widget.brandName);
              }, milliseconds: 300);
            },
            onRemove: (value) {
              DeBouncer.run(() {
                cartProvider.removeAndUpdateCart(
                  uid!,
                  product.id!,
                );
              });
            },
            onItemTap: () async {
              Get.to(ProductDetailPage(
                product: product,
                brandName: widget.brandName,
              ));
            },
          );
        },
        childCount: provider.filteredProducts.length,
      ),
    );
  }

  String? getUserId() {
    return Provider.of<AuthenticationProvider>(context, listen: false)
        .getCurrentUser();
  }
}
