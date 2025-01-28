import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CashierOrderDetailsDialog extends StatelessWidget {
  final DocumentSnapshot order;

  const CashierOrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Order Details'),
      content: SingleChildScrollView(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ${order.id}', style: mBold),
                const SizedBox(height: 10),
                Text(
                  'Customer: ${order['customerFirstName']} ${order['customerLastName']}',
                ),
                const SizedBox(height: 10),
                Text('Status: ${order['status']}', style: mRegular),
                const Divider(),
                Column(
                  children: order['cartItems'].map<Widget>((item) {
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Quantity: ${item['quantity']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Total: \$${item['total']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('Total: \$${order['cartTotal']}', style: mSemibold),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            _generateAndDisplayReceipt(order);
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Colors.orange,
            ), // Orange button
            foregroundColor: WidgetStateProperty.all<Color>(
              Colors.black,
            ), // Black text
          ),
          child: const Text(
            'Generate Receipt',
            style: TextStyle(fontSize: 13), // Adjust font size here
          ),
        ),
      ],
    );
  }

  Future<void> _generateAndDisplayReceipt(DocumentSnapshot order) async {
    // Generate PDF content
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Order Receipt', style: const pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 20),
            pw.Text('Order ID: ${order.id}'),
            pw.Text(
              'Customer: ${order['customerFirstName']} ${order['customerLastName']}',
            ),
            pw.SizedBox(height: 10),
            pw.Text('Items:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...order['cartItems'].map((item) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${item['name']}',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                    pw.Text(
                      'Quantity: ${item['quantity']}',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                    pw.Text(
                      'Total: \$${item['total']}',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                  ],
                )),
            pw.SizedBox(height: 10),
            pw.Text('Total: \$${order['cartTotal']}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
