// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/provider/auth_provider.dart';
import 'package:sanitary_mart/auth/screen/login_screen.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/order/provider/order_provider.dart';
import 'package:sanitary_mart/order/ui/order_screen.dart';
import 'package:sanitary_mart/payment/ui/payment_info_screen.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';
import 'package:sanitary_mart/profile/ui/screen/about_us.dart';
import 'package:sanitary_mart/profile/ui/screen/address_list_screen.dart';
import 'package:sanitary_mart/profile/ui/screen/personal_information_screen.dart';

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'User Profile',
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Personal Information'),
            subtitle: const Text('Manage your personal details'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Get.to(const PersonalInfoScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Orders'),
            subtitle: const Text('Review your order history'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Get.to(const OrderScreen());
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.location_on),
          //   title: const Text('Addresses'),
          //   subtitle: const Text('Manage your delivery addresses'),
          //   trailing: const Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     Get.to(AddressListScreen());
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            subtitle: const Text('Company detail and contact info'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Get.to(const AboutUsScreen());
            },
          ),ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Payment'),
            subtitle: const Text('Payment details'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Get.to(const PaymentInfoScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out from your account'),
            onTap: () {
              signOut(context);
            },
          ),
          SizedBox(
            height: Get.height * 0.2,
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Version ${snapshot.data!.version}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  void signOut(BuildContext context) async {
    AuthenticationProvider authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    await authProvider.googleSignOut();
    if (!authProvider.isError) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).reset();
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).reset();

      Get.off(LoginScreen());
    }
  }
}
