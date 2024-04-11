import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/cart/ui/screen/cart_screen.dart';
import 'package:sanitary_mart/core/widget/app_image_network_widget.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function() onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10.0), // Rounded corners for cards
      // ),
      child: Padding(
        padding: const EdgeInsets.all(8), // Adjust padding for content spacing
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              child: SizedBox(
                width: 80,
                height: 80,
                child: NetworkImageWidget(
                  cartItem.productImg!,
                ),
              ),
            ),
            const SizedBox(width: 12), // Consistent spacing between elements

            // Product Details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.productName,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2, // Allow for wrapping long product names
                            overflow: TextOverflow.ellipsis, // Ellipsis for overflowing text
                          ),
                          Text(
                            cartItem.brand,
                            style: const TextStyle(
                              fontSize: 14.0,
                            ),
                            maxLines: 2, // Allow for wrapping long product names
                            overflow: TextOverflow.ellipsis, // Ellipsis for overflowing text
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: onRemove,
                        iconSize: 28.0, // Smaller icon size
                        icon: const Icon(Icons.delete_outline), // Outline icon for better visibility
                        padding: EdgeInsets.zero, // Remove default padding
                        constraints: const BoxConstraints(), // Remove default constraints
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Reduced spacing between price and quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align price and quantity
                    children: [
                      Text(
                        '₹${cartItem.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      // Improved quantity control with Text field
                      Row(
                        mainAxisSize: MainAxisSize.min, // Fixed width for quantity section
                        children: [
                          IconButton(
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                String? uId = getUserId(context);
                                Provider.of<CartProvider>(context, listen: false)
                                    .updateCartItemQuantity(
                                  uId: uId!,
                                  productId: cartItem.productId,
                                  newQuantity: cartItem.quantity - 1,
                                );
                              }
                            },
                            iconSize: 18.0, // Smaller icon size
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            cartItem.quantity.toString(),
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          IconButton(
                            onPressed: () {
                              String? uId = getUserId(context);
                              Provider.of<CartProvider>(context, listen: false)
                                  .updateCartItemQuantity(
                                uId: uId!,
                                productId: cartItem.productId,
                                newQuantity: cartItem.quantity + 1,
                              );
                            },
                            iconSize: 18.0, // Smaller icon size
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button with smaller icon size and improved placement

          ],
        ),
      ),
    );
  }
}
