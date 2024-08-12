import 'dart:collection';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/service/cart_firebase_service.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/order/service/order_service.dart';
import 'package:sanitary_mart/product/model/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

  int totalDiscount = 0;

  List<CartItem> get cartItems =>
      _cartItems.toList(); // Return a copy of the list

  double get totalCartPrice {
    return _cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future fetchCartItems(String userId) async {
    CartFirebaseService cartService = Get.find();
    try {
      _state = ProviderState.loading;
      notifyListeners();
       _cartItems = await cartService.getCartItems(userId);
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'fetch_cart');
    } catch (e) {
      _state = ProviderState.error;
      AppUtil.showToast('Something went wrong', isError: true);
      FirebaseAnalytics.instance.logEvent(name: 'fetch_cart_error');
    } finally {
      notifyListeners();
    }
    OrderService().fetchUserOrders(userId);
  }

  Future<void> addToCart(String uid, CartItem item) async {
    try {
      CartFirebaseService cartService = Get.find();
      _state = ProviderState.loading;
      notifyListeners();
      await cartService.addToCart(uid, item);
      AppUtil.showToast('Added to cart');
      FirebaseAnalytics.instance.logEvent(name: 'add_to_cart');
    } catch (e) {
   //   Log.e(e.toString());
    } finally {
      _state = ProviderState.idle;
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String uid, String productId) async {
    _state = ProviderState.idle;
    CartFirebaseService cartService = Get.find();
    await cartService.removeProductFromCart(
        uid, productId); // Use injected service
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _cartItems.removeAt(index);
      AppUtil.showWarningToast('Item removed from cart');
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'remove_from_cart');
    }
  }

  double calculateTotalDiscount(List<CartItem> cartItems) {
    double totalDiscount = 0;
    for (var element in cartItems) {
      totalDiscount += ((element.discountAmount ?? 0) * element.quantity);
    }
    return totalDiscount;
  }

  Future<void> updateCartItemQuantity(
      {required String uId,
      required String productId,
      required int newQuantity,
      bool isRemove = false}) async {
    if (newQuantity <= 0) return; // Handle invalid quantity
    CartFirebaseService cartService = Get.find();
    await cartService.updateCartItemQuantity(
        uId, productId, newQuantity); // Use injected service
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'update_cart');
    }
  }

  void addAndUpdateCart(String uid, Product product, int quantity, brandName) {
    CartItem cartItem = CartItem(
      productId: product.id ?? "0",
      productName: product.name,
      price: product.price,
      brand: brandName,
      quantity: quantity,
      productImg: product.image,
      discountAmount: product.discountAmount,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    // Check if the item is already in the cart
    final existingItemIndex =
        cartItems.indexWhere((item) => item.productId == product.id);

    if (existingItemIndex == -1) {
      // Item is not in the cart, add it
      addToCart(uid, cartItem);
    } else {
      // Item is in the cart, update the quantity
      final existingItem = cartItems[existingItemIndex];
      updateCartItemQuantity(
        uId: uid,
        productId: product.id!,
        newQuantity: existingItem.quantity + 1, // Increase quantity by 1
      );
    }
  }

  void removeAndUpdateCart(String uid, String productId) async {
    final existingItemIndex =
        cartItems.indexWhere((item) => item.productId == productId);

    if (existingItemIndex != -1) {
      final existingItem = cartItems[existingItemIndex];
      if (existingItem.quantity > 1) {
        // If quantity is more than 1, decrease by 1
        updateCartItemQuantity(
          uId: uid,
          productId: productId,
          newQuantity: existingItem.quantity - 1, // Decrease quantity by 1
        );
      } else {
        // If quantity is 1, remove the item from the cart
        removeFromCart(uid, productId);
      }
    }
  }

  void clearCart() async {
    void reset() {
      _cartItems = [];
    }
  }
}
