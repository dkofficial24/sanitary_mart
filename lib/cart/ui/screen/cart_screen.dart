import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/provider/auth_provider.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/cart/ui/screen/checkout_screen.dart';
import 'package:sanitary_mart/cart/ui/screen/widget/cart_item_widget.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/error_retry_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchCartItems();
    });
    FirebaseAnalytics.instance.logEvent(name: 'cart_screen');
    super.initState();
  }

  void fetchCartItems() {
    String? uid = getUserId(context);
    if (uid != null) {
      Provider.of<CartProvider>(context, listen: false).fetchCartItems(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // double totalDiscount = cartProvider.cartItems.fold(
    //     0,
    //     (previousValue, cartItem) =>
    //         previousValue +
    //         ((cartItem.discountAmount ?? 0) * cartItem.quantity));

    return Consumer<CartProvider>(builder: (context, cartProvider, child) {
      double subtotal = cartProvider.cartItems.fold(
          0,
              (previousValue, cartItem) =>
          previousValue + (cartItem.price * cartItem.quantity));

      late Widget widget;

      if (cartProvider.state == ProviderState.loading) {
        widget = const Center(
          child: CircularProgressIndicator(),
        );
      } else if (cartProvider.state == ProviderState.error) {
        widget = ErrorRetryWidget(
          onRetry: () {
            fetchCartItems();
          },
        );
      } else {
        if (subtotal >= 1) {
          widget = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '₹${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return CartItemWidget(
                      cartItem: cartItem,
                      onRemove: () {
                        String? uId = getUserId(context);
                        cartProvider.removeFromCart(uId!, cartItem.productId);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: subtotal >= 1
                      ? () {
                    Get.to(CheckoutScreen(
                      cartItems: cartProvider.cartItems,
                    ));
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    // Full width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          );
        } else {
          widget = emptyState();
        }
      }

      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Cart',
        ),
        body: widget,
      );
    });
  }

  Center emptyState() {
    return Center(
      child: Text(
        'Cart is empty',
        style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
      ),
    );
  }
}



String? getUserId(BuildContext context) {
  return Provider.of<AuthenticationProvider>(context, listen: false)
      .getCurrentUser();
}