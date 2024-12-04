import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/model/end_user_model.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/translucent_overlay_loader.dart';
import 'package:sanitary_mart/order/provider/order_provider.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';
import 'package:sanitary_mart/profile/ui/screen/update_user_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final String? note;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    this.note,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isBuildingEndUser = true;

  // Simulated EndUser data (to be filled via form)
  EndUser? endUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Checkout',
      ),
      body: isBuildingEndUser ? _buildEndUserForm() : _buildCheckoutScreen(),
    );
  }

  // Widget to build EndUser form
  Widget _buildEndUserForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Your Details',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: addressController,
              maxLines: 1,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  setState(() {
                    endUser = EndUser(
                      name: nameController.text.trim(),
                      mobile: phoneController.text.trim(),
                      village: addressController.text.trim(),
                    );
                    isBuildingEndUser = false; // Switch to checkout state
                  });
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display checkout details
  Widget _buildCheckoutScreen() {
    double total = _calculateTotal();
    double totalDiscount = 0;

    UserModel? userModel = Provider.of<UserProvider>(context).userModel;
    if (userModel != null && (userModel.verified ?? false)) {
      totalDiscount = Provider.of<CartProvider>(context)
          .calculateTotalDiscount(widget.cartItems);
    }

    return Padding(
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
          Text(
            'Name: ${endUser?.name}',
            style: const TextStyle(fontSize: 16.0),
          ),
          Text(
            'Phone: ${endUser?.mobile}',
            style: const TextStyle(fontSize: 16.0),
          ),
          Text(
            'Address: ${endUser?.village}',
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return _buildOrderItem(cartItem);
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 16.0),
          _buildTotalSection(total, totalDiscount),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (endUser==null && Provider.of<OrderProvider>(context, listen: false).state ==
                  ProviderState.loading) {
                return;
              }
              confirmOrder(context);
            },
            child: const Text('Proceed to Order'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isBuildingEndUser = true; // Go back to EndUser form
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('Back to Edit Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem cartItem) {
    double itemTotal = cartItem.price * cartItem.quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.productName, overflow: TextOverflow.ellipsis),
                Text('${cartItem.price} x ${cartItem.quantity}'),
              ],
            ),
          ),
          Text('₹${itemTotal.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double total, double totalDiscount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total'),
            Text('₹${total.toStringAsFixed(2)}'),
          ],
        ),
        if (totalDiscount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount'),
              Text('- ₹${totalDiscount.toStringAsFixed(2)}'),
            ],
          ),
      ],
    );
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future confirmOrder(BuildContext context) async {
    final checkoutProvider = Provider.of<OrderProvider>(context, listen: false);
    UserModel? userModel =
        await Provider.of<UserProvider>(context, listen: false)
            .getCurrentUser();
    if (userModel != null && endUser != null) {
      endUser?.id = DateTime.now().millisecondsSinceEpoch.toString();
      checkoutProvider.placeOrder(
        cartItems: widget.cartItems,
        userModel: userModel,
        endUser: endUser!,
        note: widget.note,
      );
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'user_not_found');
      AppUtil.showToast('User not found!', isError: true);
      //  }
    }
  }
}
