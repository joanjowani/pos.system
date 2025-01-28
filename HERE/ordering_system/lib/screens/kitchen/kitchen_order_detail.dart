import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordering_system/util/app_style.dart';

class KitchenOrderDetail extends StatefulWidget {
  static const String route = '/orderdetails';
  static const String name = 'KitchenOrderDetail';

  final DocumentSnapshot order;

  const KitchenOrderDetail({required this.order, super.key});

  @override
  _KitchenOrderDetailState createState() => _KitchenOrderDetailState();
}

class _KitchenOrderDetailState extends State<KitchenOrderDetail> {
  @override
  Widget build(BuildContext context) {
    final data = widget.order.data() as Map<String, dynamic>?;

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
                Text('Order ${widget.order.id}', style: mBold),
                const SizedBox(height: 10),
                Text(
                  'Customer: ${data?.containsKey('customerFirstName') == true ? data!['customerFirstName'] : 'N/A'} ${data?.containsKey('customerLastName') == true ? data!['customerLastName'] : 'N/A'}',
                ),
                const SizedBox(height: 10),
                Text('Status: ${data?['status'] ?? 'N/A'}', style: mRegular),
                const Divider(),
                Column(
                  children:
                      (data?['cartItems'] as List<dynamic>).map<Widget>((item) {
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
                          Text('Total: \$${item['total']}',
                              style: const TextStyle(fontSize: 13))
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('Total: \$${data?['cartTotal'] ?? 'N/A'}',
                    style: mSemibold),
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
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _updateOrderStatus(widget.order.id, 'completed');
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
          ),
          child: const Text('Completed'),
        ),
      ],
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
    } catch (e) {
      // Handle error
      print('Error updating order status: $e');
    }
  }
}
