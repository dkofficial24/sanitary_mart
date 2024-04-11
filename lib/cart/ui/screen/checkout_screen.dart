import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/order/provider/order_provider.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key, required this.cartItems});

  final List<CartItem> cartItems;
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController(text: 'Test Name');
  final TextEditingController phoneController = TextEditingController(text: '567890');
  final TextEditingController addressController = TextEditingController(text: 'Test Address');

  @override
  Widget build(BuildContext context) {
    double total = _calculateTotal();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Checkout',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Review Your Order',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index];
                  return _buildOrderItem(cartItem);
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            _buildTotalSection(total),
            const SizedBox(height: 16.0),
            Form(
              key: formKey,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    // Full width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                onPressed: () {
                  if (Provider.of<OrderProvider>(context, listen: false)
                          .state ==
                      ProviderState.loading) {
                    return;
                  }
                  confirmOrder(context);
                  // showAddressBottomSheet(context);
                },
                child: const Text('Proceed to Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddressBottomSheet(BuildContext context) {
    Get.bottomSheet(Container(
      height: Get.height * 0.5,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input phone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (Provider.of<OrderProvider>(context,listen: false).state ==
                        ProviderState.loading) {
                      return;
                    }
                    confirmOrder(context);
                  },
                  child: const Text('Confirm Order'))
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildOrderItem(CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.productName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Qty: ${cartItem.quantity}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text('₹${cartItem.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '₹${total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var cartItem in cartItems) {
      total += cartItem.price * cartItem.quantity;
    }
    return total;
  }

  Future confirmOrder(BuildContext context) async {
    // if (formKey.currentState?.validate() ?? false) {
    // String name = nameController.text.trim();
    // String phone = phoneController.text.trim();
    // String address = addressController.text.trim();

    final checkoutProvider = Provider.of<OrderProvider>(context, listen: false);
    UserModel? userModel =
        await Provider.of<UserProvider>(context, listen: false)
            .getCurrentUser();
    if (userModel != null) {
      checkoutProvider.placeOrder(cartItems: cartItems, userModel: userModel);
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'user_not_found');
      AppUtil.showToast('User not found!');
      //  }
    }
  }
}
