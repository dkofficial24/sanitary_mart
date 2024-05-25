import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';

class UpdateUserDetailsScreen extends StatefulWidget {
  const UpdateUserDetailsScreen({
    required this.updateUserModel,
    Key? key,
  }) : super(key: key);
  final UpdateUserModel updateUserModel;

  @override
  _UpdateUserDetailsScreenState createState() =>
      _UpdateUserDetailsScreenState();
}

class _UpdateUserDetailsScreenState extends State<UpdateUserDetailsScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    initFields();
    super.initState();
  }

  void initFields() {
    _userNameController.text = widget.updateUserModel.userName ?? '';
    _emailController.text = widget.updateUserModel.email ?? '';
    _mobileController.text = widget.updateUserModel.phone ?? '';
    _addressController.text = widget.updateUserModel.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (BuildContext context, UserProvider provider, Widget? child) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Update user details',
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _userNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    readOnly: true,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _addressController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter your address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_mobileController.text.isEmpty) {
                          AppUtil.showToast("Mobile field can't be empty");
                          return;
                        }
                        updateUserDetail(provider).then((bool updateSuccess) {
                          if (updateSuccess) {
                            Get.back(result: updateSuccess);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> updateUserDetail(UserProvider userProvider) async {
    String mobileNumber = _mobileController.text;
    String address = _addressController.text;
    String userName = _userNameController.text;
    String email = _emailController.text;

    await userProvider.updateUserDetail(UpdateUserModel(
      uId: widget.updateUserModel.uId,
      userName: userName,
      address: address,
      email: email,
      phone: mobileNumber,
    ));

    return userProvider.providerState == ProviderState.idle;
  }
}
