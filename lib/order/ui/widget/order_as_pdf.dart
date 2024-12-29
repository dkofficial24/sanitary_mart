import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/order/model/order_model.dart';
import 'package:sanitary_mart/order/model/order_status.dart';

import 'package:share_plus/share_plus.dart';

Future<void> shareOrderAsPdf(BuildContext context, OrderModel order) async {
  pw.Document pdf = createPdfDocument(order);

  // Get the directory for storing PDF files
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;

  // Save the PDF document to a file
  Uint8List file = await pdf.save();
  final filePath = '$path/order_${order.orderId}.pdf';
  File(filePath).writeAsBytesSync(file);

  // Share the PDF file
  // You can use any method to share the file, such as Share package or sending it via email
  // For example, you can use Share package:
  await Share.shareFiles([filePath], text: 'Order ${order.orderId}');
}

Future<String> getExternalDocumentPath() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  Directory _directory = Directory("");
  if (Platform.isAndroid) {
    _directory = Directory("/storage/emulated/0/Download");
  } else {
    _directory = await getApplicationDocumentsDirectory();
  }

  final exPath = _directory.path;
  print("Saved Path: $exPath");
  await Directory(exPath).create(recursive: true);
  return exPath;
}

Future<void> downloadOrderAsPdf(BuildContext context, OrderModel order) async {
  pw.Document pdf = createPdfDocument(order);
  final path = await getExternalDocumentPath();
  final filePath =
      join(path, 'order_${order.orderId}.pdf'); // Combine path and filename
  if (!await Directory(path).exists()) {
    AppUtil.showToast('Unable to create folder', isError: true);
    return;
  }
  Uint8List bytes = await pdf.save();
  File filed = File(filePath);
  await filed.writeAsBytes(
    bytes,
    mode: FileMode.write,
  );
  AppUtil.showPositiveToast('Bill downloaded successfully');
}

pw.Document createPdfDocument(OrderModel order) {
  double total = 0;
  double discount = 0;

  // Calculate total and discount based on order items
  for (var item in order.orderItems) {
    total += item.price * item.quantity;
    discount += item.discountAmount * item.quantity;
  }

  // Create a PDF document
  final pdf = pw.Document();

  // Add multi-page content to the PDF
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(10),
      build: (pw.Context context) {
        return [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Shree Balaji Sanitary & Electronics',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Bhiwani Road, Bahal',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Phone: 9555294879',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 4),
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text('Customer Name: ',
                      style: pw.TextStyle(fontSize: 14.0)),
                  pw.Text(order.endUser?.name.capitalize ?? 'NA',
                      style: pw.TextStyle(fontSize: 14.0)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text('Mobile: ', style: pw.TextStyle(fontSize: 14.0)),
                  pw.Text(order.endUser?.mobile ?? 'NA',
                      style: pw.TextStyle(fontSize: 14.0)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text('Address: ', style: pw.TextStyle(fontSize: 14.0)),
                  pw.Text(order.endUser?.village ?? 'NA',
                      style: pw.TextStyle(fontSize: 14.0)),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Text('Order ID: ${order.orderId}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.Text('Date: ${_formatDate(order.createdAt)}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text('Items:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 10),
            ],
          ),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Sr', 'Items', 'Qty', 'Price', 'Total'],
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 14),
            data: order.orderItems.map((item) {
              return [
                (order.orderItems.indexOf(item) + 1).toString(),
                item.productName,
                item.quantity.toString(),
                item.price.toStringAsFixed(2),
                (item.price * item.quantity).toStringAsFixed(2),
              ];
            }).toList(),
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('SubTotal:', style: const pw.TextStyle(fontSize: 16)),
              pw.Text(
                total.toStringAsFixed(2),
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        ];
      },
    ),
  );
  return pdf;
}

String _formatDate(int? timestamp) {
  if (timestamp == null) return 'Unknown date';
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat.yMMMd().format(date); // Example format: Jan 28, 2020
}

PdfColor _getStatusColor(OrderStatus orderStatus) {
  switch (orderStatus) {
    case OrderStatus.pending:
      return PdfColors.purple;
    case OrderStatus.delivered:
      return PdfColors.green;
    case OrderStatus.canceled:
      return PdfColors.red;
    case OrderStatus.returned:
      return PdfColors.orange;
    default:
      return PdfColors.black;
  }
}
