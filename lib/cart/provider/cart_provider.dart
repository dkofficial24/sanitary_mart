import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/service/cart_service.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/order/service/order_service.dart';

class CartProvider extends ChangeNotifier {

  List<CartItem> _cartItems = [];
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

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
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'fetch_cart');
    } catch (e) {
      AppUtil.showToast('Something went wrong');
      FirebaseAnalytics.instance.logEvent(name: 'fetch_cart_error');
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
      Log.e(e.toString());
    } finally {
      _state = ProviderState.idle;
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String uid, String productId) async {
    CartFirebaseService cartService = Get.find();
    await cartService.removeProductFromCart(uid,productId); // Use injected service
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _cartItems.removeAt(index);
      AppUtil.showToast('Item removed from cart');
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'remove_from_cart');
    }
  }

  Future<void> updateCartItemQuantity({
    required String uId,
    required String productId,
    required int newQuantity,
  }) async {
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

  void clearCart() async {
    // await _cartService
    //     .clearCart(uid); // Call clearCart method in service (if available)
    // _cartItems.clear();
    // notifyListeners();
  }

  void reset(){
    _cartItems = [];
  }
}
