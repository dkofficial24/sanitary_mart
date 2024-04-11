import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';
import 'package:sanitary_mart/profile/ui/screen/edit_personal_information_screen.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Personal Information',
        // actions: [
        //   // IconButton(
        //   //   icon: const Icon(Icons.edit),
        //   //   onPressed: () {
        //   //     Navigator.push(
        //   //       context,
        //   //       MaterialPageRoute(
        //   //         builder: (context) => EditPersonalInformationScreen(),
        //   //       ),
        //   //     );
        //   //   },
        //   // ),
        // ],
      ),
      body: FutureBuilder<UserModel?>(
        future:
            Provider.of<UserProvider>(context, listen: false).getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            final UserModel userModel = snapshot.data!;
            return ListView(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Full Name'),
                  subtitle: Text(userModel.userName),
                ),
                const ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Mobile Number'),
                  subtitle: Text('-'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(userModel.email),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
