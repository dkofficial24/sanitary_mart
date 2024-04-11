import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/provider/auth_provider.dart';
import 'package:sanitary_mart/core/constant/constant.dart';
import 'package:sanitary_mart/core/widget/custom_button.dart';
import 'package:sanitary_mart/core/widget/custom_loader.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AuthenticationProvider>(
          builder: (context, authProvider, child) {
            return CustomLoader(
              showLoader: authProvider.isLoading,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  //  const AppLogo(),
                  //   const SizedBox(
                  //     height: 16,
                  //   ),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return AppText.invalidPhoneNo;
                          }
                          return null;
                        },
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColor.fieldTextColor),
                        decoration: InputDecoration(
                          hintText: AppText.phoneFieldHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomButton(
                      name: AppText.next,
                      onPressed:null
                      //   () {
                      //   login(context);
                      // },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width*0.4,
                            child: const Divider(endIndent: 8,)),
                        Text('OR'),
                        SizedBox(
                            width: MediaQuery.of(context).size.width*0.4,
                            child: const Divider(indent: 8,)),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomButton(
                      name: 'Google sign in',
                      onPressed: () {
                        final authProvide = Provider.of<AuthenticationProvider>(
                            context,
                            listen: false);
                        authProvide.signInWithGoogle();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void login(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      String phoneNumber = phoneController.text;
      phoneNumber = '+91$phoneNumber';
      final authProvide =
          Provider.of<AuthenticationProvider>(context, listen: false);
      authProvide.phoneLogin(phoneNumber);
    }
  }
}
