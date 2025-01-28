import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'cashier_order_details.dart';
import 'package:ordering_system/dialog/dialog.dart';

class CashierHomeScreen extends StatefulWidget {
  static const String route = '/cashierhome';
  static const String name = 'CashierHomeScreen';

  const CashierHomeScreen({super.key});

  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cashier Interface',
          style: mExtraBold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              WaitingDialog.show(context, future: AuthController.I.logout());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching orders'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No completed orders'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>?;
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: const Color.fromRGBO(255, 153, 0, 1), // Orange color
                child: ListTile(
                  title: Text('Order ${order.id}', style: mSemibold),
                  subtitle: Text(
                    'Status: ${data?['status'] ?? 'N/A'}',
                    style: mRegular.copyWith(color: Colors.white),
                  ),
                  onTap: () => _showOrderDetails(context, order),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, DocumentSnapshot order) {
    showDialog(
      context: context,
      builder: (context) {
        return CashierOrderDetailsDialog(order: order);
      },
    );
  }
}
