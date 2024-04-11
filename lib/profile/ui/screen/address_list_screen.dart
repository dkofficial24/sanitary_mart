import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/profile/model/user_address_model.dart';

class AddressListScreen extends StatelessWidget {
  final List<UserAddress> addresses = [
    UserAddress(
      id: '1',
      fullAddress: '123 Cherry Lane',
      state: 'California',
      city: 'Los Angeles',
      zipcode: '90001',
    ),
    UserAddress(
      id: '2',
      fullAddress: '456 Maple Street',
      state: 'New York',
      city: 'New York City',
      zipcode: '10001',
    ),
    // Add more addresses as needed for your mock data
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Your Addresses',
      ),
      body: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          UserAddress address = addresses[index];
          return ListTile(
            title: Text(address.fullAddress),
            subtitle:
                Text('${address.city}, ${address.state} ${address.zipcode}'),
            trailing: Icon(Icons.edit), // Example: An edit icon
            onTap: () {
              // Handle the tap event, maybe open an edit screen
            },
          );
        },
      ),
    );
  }
}
