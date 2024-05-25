import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sanitary_mart/payment/model/account_info_model.dart';
import 'package:share_plus/share_plus.dart';

class PaymentService {
  void sharePaymentInfo(PaymentInfo paymentInfo) async {
    const String text = '''
    Name: paymentInfo.accountHolderName 
    UPI Id: paymentInfo.upiId 
    ''';

    if (paymentInfo.qrCodeUrl.isNotEmpty) {
      try {
        final url = paymentInfo.qrCodeUrl;
        final response = await http.get(Uri.parse(url));
        final directory = await getApplicationDocumentsDirectory();

        final file = File('${directory.path}/qr_code.png');
        file.writeAsBytesSync(response.bodyBytes);

        Share.shareXFiles([XFile(file.path)], text: text);
      } catch (e) {
        print('Error downloading or sharing the image: $e');
        Share.share(text);
      }
    } else {
      Share.share(text);
    }
  }
}
