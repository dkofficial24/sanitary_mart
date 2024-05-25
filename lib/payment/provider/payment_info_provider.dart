import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/payment/model/account_info_model.dart';
import 'package:sanitary_mart/payment/service/payment_firebase_service.dart';
import 'package:sanitary_mart/payment/service/payment_service.dart';
import 'package:share_plus/share_plus.dart';

class PaymentInfoProvider extends ChangeNotifier {
  PaymentInfo? paymentInfo;
  ProviderState providerState = ProviderState.idle;
  bool isUploading = false;

  Future fetchPaymentInfo({bool refresh = false}) async {
    if (!refresh && paymentInfo != null) return;
    try {
      print('fetchPaymentInfo');
      providerState = ProviderState.loading;
      notifyListeners();
      PaymentFirebaseService adminService = Get.find<PaymentFirebaseService>();
      paymentInfo = await adminService.fetchPaymentInfo();
      providerState = ProviderState.idle;
    } catch (e) {
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void sharePaymentInfo(PaymentInfo paymentInfo) async {
    Get.find<PaymentService>().sharePaymentInfo(paymentInfo);
  }

}
