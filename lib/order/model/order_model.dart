import 'package:sanitary_mart/order/model/order_item.dart';
import 'package:sanitary_mart/order/model/order_status.dart';

class OrderModel {
  String orderId;
  List<OrderItem> orderItems;
  int? createdAt;
  int? updatedAt;
  OrderStatus orderStatus;
  Customer? customer;
  bool userVerified;

  OrderModel({
    required this.orderId,
    required this.orderItems,
    this.customer,
    this.orderStatus = OrderStatus.pending,
    this.createdAt,
    this.updatedAt,
    this.userVerified=false,
  });

  // Convert OrderModel instance to Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'orderStatus': orderStatus.name,
      'userVerified': userVerified,
    };
  }

  // Construct an OrderModel instance from a Map
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['orderItems'] as List;
    List<OrderItem> orderItemsList =
        list.map((i) => OrderItem.fromJson(i)).toList();
    return OrderModel(
      orderId: json['orderId'],
      orderItems: orderItemsList,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userVerified: json['userVerified'] ?? false,
      orderStatus: parseOrderStatus(json['orderStatus']),
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }
}

class Customer {
  String uId;
  String userName;
  String email;
  String phone;
  String userDeviceToken;

  Customer({
    required this.uId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.userDeviceToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'userDeviceToken': userDeviceToken,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      uId: json['uId'],
      userName: json['userName'],
      email: json['email'],
      phone: json['phone'],
      userDeviceToken: json['userDeviceToken'],
    );
  }
}
