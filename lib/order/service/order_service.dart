import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart/order/model/order_model.dart';

class OrderService {
  Future placeOrder(OrderModel order) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(order.customer!.uId)
        .set(order.customer!.toJson());

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(order.customer!.uId)
        .collection('confirmOrders')
        .doc(order.orderId)
        .set(order.toJson());
  }

  Future<List<OrderModel>> fetchUserOrders(String uId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('orders').doc(uId).get();

    if (!userSnapshot.exists) {
      return [];
    }
    Customer customer =
        Customer.fromJson(userSnapshot.data() as Map<String, dynamic>);

    final ordersSnapshot = (await FirebaseFirestore.instance
        .collection('orders')
        .doc(uId)
        .collection('confirmOrders')
        .orderBy('createdAt', descending: true)
        .get());

    final orders = ordersSnapshot.docs.map((doc) {
      print('');
      OrderModel orderModel = OrderModel.fromJson(doc.data());
      orderModel.customer = customer;
      return orderModel;
    }).toList();

    return orders;
  }
}
