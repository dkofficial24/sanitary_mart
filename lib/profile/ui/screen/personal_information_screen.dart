import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';
import 'package:sanitary_mart/profile/ui/screen/update_user_detail_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchUserData();
    });
  }

  Future<void> _fetchUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _updateUserDetails(context);
        },
        child: const Icon(Icons.edit),
      ),
      appBar: const CustomAppBar(
        title: 'User details',
      ),
      body: Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider provider, Widget? child) {
          if (provider.providerState == ProviderState.loading) {
            return const CircularProgressIndicator();
          } else if (provider.providerState == ProviderState.error) {
            return ErrorRetryWidget(onRetry: () {
              _fetchUserData();
            });
          } else if (provider.userModel == null) {
            return const Center(
              child: Text('No user details available'),
            );
          }

          return ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Full Name'),
                subtitle: Text(provider.userModel!.userName),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Mobile Number'),
                subtitle: Text(provider.userModel!.phone ?? '-'),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(provider.userModel!.email),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Address'),
                subtitle: Text(provider.userModel!.address ?? '-'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUserDetails(BuildContext context) async {
    UserProvider provider = Provider.of<UserProvider>(context,listen: false);

    if (provider.userModel != null) {
      await Get.to(() => UpdateUserDetailsScreen(
          updateUserModel: UpdateUserModel.fromUserModel(provider.userModel!)));
      _fetchUserData();
    }
  }
}
