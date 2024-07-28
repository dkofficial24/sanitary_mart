import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart/payment/model/account_info_model.dart';

class PaymentFirebaseService {
  final String collectionName = 'payment_details';

  Future<List<PaymentInfo>> fetchPaymentInfo() async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    return snapshot.docs.map((doc) => PaymentInfo.fromFirebase(doc)).toList();
    throw 'Payment info not available';
  }
}
