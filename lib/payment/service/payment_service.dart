import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sanitary_mart/payment/model/account_info_model.dart';
import 'package:share_plus/share_plus.dart';

class PaymentService {
  Future sharePaymentInfo(
      {required PaymentInfo paymentInfo, double? totalPayable}) async {
    String details = '''
    Name: ${paymentInfo.accountHolderName}
    UPI Id: ${paymentInfo.upiId} 
    ''';

    if(totalPayable!=null) {
      details += 'Total Amount: $totalPayable';
    }

    if (paymentInfo.qrCodeUrl.isNotEmpty) {
      try {
        final url = paymentInfo.qrCodeUrl;
        final response = await http.get(Uri.parse(url));
        final directory = await getApplicationDocumentsDirectory();

        final file = File('${directory.path}/qr_code.png');
        file.writeAsBytesSync(response.bodyBytes);

        Share.shareXFiles([XFile(file.path)], text: details);
      } catch (e) {
        print('Error downloading or sharing the image: $e');
        Share.share(details);
      }
    } else {
      Share.share(details);
    }
  }
}
