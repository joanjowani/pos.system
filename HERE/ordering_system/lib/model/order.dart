import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordering_system/model/cart.dart';

class OrderItem {
  final String id;
  final String status;
  final DateTime createdAt;
  final String customerID;
  final String customerFirstName;
  final String customerLastName;
  final double cartTotal;
  final List<CartItem> cartItems;

  OrderItem({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.customerID,
    required this.customerFirstName,
    required this.customerLastName,
    required this.cartTotal,
    required this.cartItems,
  });

  factory OrderItem.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderItem(
      id: id,
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      customerID: data['customerID'] ?? '',
      customerFirstName: data['customerFirstName'] ?? '',
      customerLastName: data['customerLastName'] ?? '',
      cartTotal: (data['cartTotal'] ?? 0.0).toDouble(),
      cartItems: (data['cartItems'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'createdAt': createdAt,
      'customerID': customerID,
      'customerFirstName': customerFirstName,
      'customerLastName': customerLastName,
      'cartTotal': cartTotal,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
    };
  }
}
