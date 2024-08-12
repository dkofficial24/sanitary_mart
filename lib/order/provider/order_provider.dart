import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/cart/model/cart_item_model.dart';
import 'package:sanitary_mart/cart/service/cart_firebase_service.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/dashboard/ui/dashboard_screen.dart';
import 'package:sanitary_mart/notification/model/notification_model.dart';
import 'package:sanitary_mart/notification/service/notification_service.dart';
import 'package:sanitary_mart/order/model/order_item.dart';
import 'package:sanitary_mart/order/model/order_model.dart';
import 'package:sanitary_mart/order/model/order_status.dart';
import 'package:sanitary_mart/order/service/order_service.dart';
import 'package:sanitary_mart/order/ui/order_screen.dart';
import 'package:sanitary_mart/payment/ui/payment_info_screen.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';

class OrderProvider extends ChangeNotifier {
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

  List<OrderModel>? orderModelList;
  List<OrderModel>? filteredOrderModelList;

  Future placeOrder(
      {required List<CartItem> cartItems,
      required UserModel userModel,
      String? note}) async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      List<OrderItem> orderItems = [];
      var totalPayable = 0.0;
      var totalIncentivePoints = 0.0;
      for (int i = 0; i < cartItems.length; i++) {
        orderItems.add(OrderItem.fromCartItem(cartItems[i]));
        totalPayable += (cartItems[i].price * cartItems[i].quantity);
        totalIncentivePoints += ((cartItems[i].discountAmount ?? 0) / 10);
      }
      String orderId = AppUtil.generateOrderId();

      OrderModel order = OrderModel(
          orderId: orderId,
          orderItems: orderItems,
          orderStatus: OrderStatus.pending,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          userVerified: userModel.verified ?? false,
          note: note,
          customer: Customer(
            uId: userModel.uId,
            userName: userModel.userName,
            email: userModel.email,
            phone: userModel.phone ?? '',
            userDeviceToken: userModel.userDeviceToken,
            address: userModel.address,
          ));

      await Get.find<OrderService>().placeOrder(order);
      await Get.find<NotificationService>()
          .createNotification(NotificationModel(
        orderId: orderId,
        userId: userModel.uId,
        userName: userModel.userName,
        noOfItem: orderItems.length,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'unread',
        type: 'order_arrival',
      ));

      if (userModel.verified ?? false) {
        Get.find<UserFirebaseService>().updateIncentivePoints(
          order.customer!.uId,
          totalIncentivePoints,
        );
      }
      await Get.find<CartFirebaseService>().clearFullCart(order.customer!.uId);
      AppUtil.showPositiveToast('Order placed successfully !');
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'order_placed');
      await Get.find<OrderService>().fetchUserOrders(order.customer!.uId);
      _state = ProviderState.idle;
      await Get.to(PaymentInfoScreen(
        totalPayable: totalPayable,
      ));
      Get.offAll(const DashboardScreen());
      Get.to(const OrderScreen());
    } catch (e) {
      _state = ProviderState.error;
      AppUtil.showToast('Something went wrong!', isError: true);
      FirebaseAnalytics.instance.logEvent(name: 'error_order_placed');
      Log.e(e);
    } finally {
      notifyListeners();
    }
  }

  Future loadOrders(String uId) async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      filteredOrderModelList =
          orderModelList = await Get.find<OrderService>().fetchUserOrders(uId);
      _state = ProviderState.idle;
    } catch (e) {
      _state = ProviderState.error;
      Log.e(e);
      filteredOrderModelList = orderModelList = [];
      FirebaseAnalytics.instance.logEvent(name: 'load_orders');
    } finally {
      notifyListeners();
    }
  }

  void filterOrderByStatus(OrderStatus? orderStatus) {
    if (orderStatus == null) {
      filteredOrderModelList = orderModelList;
      notifyListeners();
      return;
    }
    filteredOrderModelList = orderModelList
        ?.where((element) => element.orderStatus == orderStatus)
        .toList();
    notifyListeners();
  }

  void reset() {
    orderModelList = [];
    filteredOrderModelList = [];
  }
}
