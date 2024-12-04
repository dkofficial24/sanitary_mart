import 'package:sanitary_mart/core/model/end_user_model.dart';
import 'package:sanitary_mart/order/model/order_item.dart';
import 'package:sanitary_mart/order/model/order_status.dart';

class OrderModel {
  String orderId;
  List<OrderItem> orderItems;
  int? createdAt;
  int? updatedAt;
  OrderStatus orderStatus;
  Customer? customer;
  EndUser? endUser;
  bool userVerified;
  String? note;

  OrderModel({
    required this.orderId,
    required this.orderItems,
    this.customer,
    this.endUser,
    this.orderStatus = OrderStatus.pending,
    this.createdAt,
    this.updatedAt,
    this.userVerified = false,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'orderStatus': orderStatus.name,
      'userVerified': userVerified,
      'note': note,
      'customer': customer != null ? customer!.toJson() : null,
      'endUser': endUser != null ? endUser!.toJson() : null,
    };
  }

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
      note: json['note'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      endUser:
          json['endUser'] != null ? EndUser.fromJson(json['endUser']) : null,
    );
  }
}

class Customer {
  String uId;
  String userName;
  String email;
  String phone;
  String userDeviceToken;
  String? address;

  Customer({
    required this.uId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.userDeviceToken,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'userDeviceToken': userDeviceToken,
      'address': address,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      uId: json['uId'],
      userName: json['userName'],
      email: json['email'],
      phone: json['phone'],
      userDeviceToken: json['userDeviceToken'],
      address: json['address'],
    );
  }
}
