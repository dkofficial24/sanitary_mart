import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/intl.dart';
import 'package:sanitary_mart/core/widget/copy_button_widget.dart';
import 'package:sanitary_mart/order/model/order_model.dart';
import 'package:sanitary_mart/order/model/order_status.dart';
import 'package:sanitary_mart/order/ui/widget/order_as_pdf.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = 0;
    double discount = 0;
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shri Balaji Sanitary & Electric',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      shareOrderAsPdf(context, order);
                    },
                    icon: const Icon(Icons.share)),
                IconButton(
                    onPressed: () {
                      downloadOrderAsPdf(context, order);
                    },
                    icon: const Icon(Icons.download))
              ],
            ),
            const Text(
              'Bhiwani Road, Bahal',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            const Text(
              'Phone: 9555294879',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Customer Name: ', style: TextStyle(fontSize: 14.0)),
                Text(order.endUser?.name.capitalize ?? 'NA',
                    style: const TextStyle(
                      fontSize: 14.0,
                    )),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Mobile: ', style: TextStyle(fontSize: 14.0)),
                Text(order.endUser?.mobile ?? 'NA',
                    style: const TextStyle(
                      fontSize: 14.0,
                    )),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Address: ', style: TextStyle(fontSize: 14.0)),
                Text(order.endUser?.village ?? 'NA',
                    style: const TextStyle(
                      fontSize: 14.0,
                    )),
              ],
            ),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Order ID: ${order.orderId}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CopyIconButton(order.orderId)
              ],
            ),
            Text('Date: ${_formatDate(order.createdAt)}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(fontSize: 14.0)),
                Text(
                  '${order.orderStatus.name.capitalize}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(order.orderStatus),
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 10,
                dataRowMaxHeight: 65,
                columns: const [
                  // DataColumn(label: Text('Sr')),
                  DataColumn(
                    label: SizedBox(child: Text('Items')),
                  ),
                  DataColumn(
                    label: Text('Qty'),
                  ),
                  DataColumn(
                    label: Text('Price'),
                  ),
                  DataColumn(
                    label: Text('Total'),
                  ),
                ],
                rows: order.orderItems.map((item) {
                  double itemTotal = item.price * item.quantity;
                  total += itemTotal;
                  discount += item.discountAmount * item.quantity;

                  return DataRow(
                    cells: [
                      // DataCell(Text(
                      //   (order.orderItems.indexOf(item) + 1).toString(),
                      // )),
                      DataCell(
                        SizedBox(
                          child: Text(item.productName),
                          // width: 100,
                        ),
                      ),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text((item.price).toStringAsFixed(2))),
                      DataCell(Text((itemTotal.toStringAsFixed(2)))),
                    ],
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            // Summary Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 14.0)),
                      Text(
                        total.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  if (discount > 0 && order.userVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Points:',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          (discount / 10).toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd().format(date); // Example format: Jan 28, 2020
  }

  Color getStatusColor(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.orange;
      default:
        return Colors.black87;
    }
  }
}
