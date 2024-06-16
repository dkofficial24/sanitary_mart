import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/payment/model/account_info_model.dart';
import 'package:sanitary_mart/payment/service/payment_firebase_service.dart';
import 'package:sanitary_mart/payment/service/payment_service.dart';

class PaymentInfoProvider extends ChangeNotifier {
  List<PaymentInfo> paymentInfoList = [];
  ProviderState providerState = ProviderState.idle;
  bool isUploading = false;

  Future fetchPaymentInfo({bool refresh = false}) async {
    //if (!refresh && paymentInfo != null) return;
    try {
      print('fetchPaymentInfo');
      providerState = ProviderState.loading;
      notifyListeners();
      PaymentFirebaseService adminService = Get.find<PaymentFirebaseService>();
      paymentInfoList = await adminService.fetchPaymentInfo();
      providerState = ProviderState.idle;
    } catch (e) {
      paymentInfoList = [];
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void sharePaymentInfo({
    required PaymentInfo paymentInfo,
    double? totalPayable,
  }) async {
    Get.find<PaymentService>()
        .sharePaymentInfo(paymentInfo: paymentInfo, totalPayable: totalPayable);
  }
}
