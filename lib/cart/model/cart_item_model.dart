class CartItem {
  String productId;
  String productName;
  String brand;
  double price;
  int quantity;
  int? createdAt;
  int? updatedAt;
  String? productImg;
  double? discountAmount;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.brand,
    this.productImg,
    this.createdAt,
    this.updatedAt,
    this.discountAmount,
  });

  // Convert CartItem object to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'brand': brand,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'imgUrl': productImg,
      'discountAmount': discountAmount,
    };
  }

  // Create a CartItem object from a Map received from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      productName: json['productName'],
      price: json['price'],
      quantity: json['quantity'],
      brand: json['brand'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      productImg: json['imgUrl'],
      discountAmount: json['discountAmount'],
    );
  }
}
