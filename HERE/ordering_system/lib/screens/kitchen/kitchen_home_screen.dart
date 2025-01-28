import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'package:ordering_system/dialog/dialog.dart';
import 'kitchen_order_detail.dart';

class KitchenHomeScreen extends StatefulWidget {
  static const String route = '/kitchenhome';
  static const String name = 'KitchenHomeScreen';

  const KitchenHomeScreen({super.key});

  @override
  State<KitchenHomeScreen> createState() => _KitchenHomeScreenState();
}

class _KitchenHomeScreenState extends State<KitchenHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig().init(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kitchen Interface',
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Orders'),
            Tab(text: 'Completed Orders'),
          ],
          indicatorColor: const Color.fromRGBO(255, 153, 0, 1),
          labelColor: const Color.fromRGBO(
              255, 153, 0, 1), // Text color for selected tab
          unselectedLabelColor: Colors.grey, // Text color for unselected tabs
          indicatorWeight: 4.0, // Thickness of the indicator line
          indicatorPadding: const EdgeInsets.symmetric(vertical: 4.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching orders'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No orders'));
            }

            final pendingOrders = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'pending';
            }).toList();

            final completedOrders = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'completed';
            }).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(pendingOrders),
                _buildOrderList(completedOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final data = order.data() as Map<String, dynamic>?;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: const Color.fromRGBO(255, 153, 0, 1),
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
  }

  void _showOrderDetails(BuildContext context, DocumentSnapshot order) {
    showDialog(
      context: context,
      builder: (context) {
        return KitchenOrderDetail(order: order);
      },
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}
