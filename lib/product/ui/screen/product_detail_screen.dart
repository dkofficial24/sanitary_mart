// product_detail_page.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/provider/auth_provider.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/debouncer.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/app_image_network_widget.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/dashboard/ui/dashboard_screen.dart';
import 'package:sanitary_mart/product/model/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final String brandName;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.brandName,
  });

  @override
  ProductDetailPageState createState() => ProductDetailPageState();
}

class ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAnalytics.instance.logEvent(name: 'pdp_cart');
                Get.offAll(()=>const DashboardScreen(
                  selectedTab: 1,
                ));
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 200.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NetworkImageWidget(widget.product.image),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '₹${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      //color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_quantity > 1) {
                            _quantity--;
                            _quantityController.text = _quantity.toString();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 10.0),
                    // Add some spacing between buttons and text field
                    SizedBox(
                      width: 50.0, // Set a fixed width for the text field
                      child: TextField(
                        controller: _quantityController,
                        // Use a TextEditingController
                        keyboardType: TextInputType.number,
                        // Set keyboard type to number
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder
                              .none, // Remove default border for cleaner look
                        ),
                        onChanged: (value) {
                          int newValue = int.tryParse(value) ?? 0;
                          if (newValue >= 1) {
                            if (newValue >= 999) {
                              onMaxQtyOverflow();
                            }
                            setState(() {
                              _quantity = newValue;
                            });
                          }else{
                            setState(() {
                              _quantity = 0;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    // Add some spacing between text field and button
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                          if (_quantity >= 999) {
                            onMaxQtyOverflow();
                          }
                          _quantityController.text = _quantity.toString();
                        });
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    DeBouncer.run(() {
                      addToCart();
                    });
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onMaxQtyOverflow() {
    _quantity = 999;
    _quantityController.text = '999';
    AppUtil.showToast('999 max quantity allowed');
  }

  String? getUserId() {
    return Provider.of<AuthenticationProvider>(context, listen: false)
        .getCurrentUser();
  }

  void addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.state == ProviderState.loading) {
      return;
    }

    if (_quantity == 0) {
      AppUtil.showToast('Quantity value can not be empty');
      return;
    }

    double discount = widget.product.discountAmount;

    CartItem cartItem = CartItem(
      productId: widget.product.id ?? "0",
      productName: widget.product.name,
      price: widget.product.price,
      brand: widget.brandName,
      quantity: _quantity,
      productImg: widget.product.image,
      discountAmount: discount,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    String? uid = getUserId();
    cartProvider.addToCart(uid!, cartItem);
  }
}
