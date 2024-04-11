class UserAddress {
  String? id;
  String fullAddress;
  String state;
  String city;
  String zipcode;

  UserAddress({
    this.id,
    required this.fullAddress,
    required this.state,
    required this.city,
    required this.zipcode,
  });

  // Convert a Address object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullAddress': fullAddress,
      'state': state,
      'city': city,
      'zipcode': zipcode,
    };
  }

  // Convert a Map object into a Address object
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      fullAddress: json['fullAddress'],
      state: json['state'],
      city: json['city'],
      zipcode: json['zipcode'],
    );
  }
}
