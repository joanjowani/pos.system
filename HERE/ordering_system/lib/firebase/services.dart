import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ordering_system/model/cart.dart';
import 'package:ordering_system/model/menu.dart';
import 'package:ordering_system/model/user.dart' as custom_user;
import 'package:ordering_system/model/order.dart';

class FirebaseServices extends ChangeNotifier {
  List<MenuItem> _menuItems = [];
  List<MenuItem> get menuItems => _menuItems;
  List<custom_user.User> _users = [];
  List<custom_user.User> get users => _users;
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;
  List<OrderItem> _orderItems = []; // Define _orders for storing fetched orders
  List<OrderItem> get orderItems => _orderItems; // Getter for _orders

  // USERS
  Future<void> fetchUsers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      _users = snapshot.docs.map((doc) {
        return custom_user.User(
          id: doc.id,
          firstName: doc['firstName'] ?? '',
          lastName: doc['lastName'] ?? '',
          email: doc['email'] ?? '',
          role: doc['role'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> addUser(String firstName, String lastName, String email,
      String password, String role) async {
    try {
      firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
      });
      await fetchUsers();
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  Future<void> editUser(custom_user.User user, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'role': role,
      });

      await fetchUsers();
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<custom_user.User> findUser(firebase_auth.User user) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return custom_user.User(
          id: doc.id,
          firstName: doc['firstName'] ?? '',
          lastName: doc['lastName'] ?? '',
          email: doc['email'] ?? '',
          role: doc['role'] ?? '',
        );
      } else {
        throw Exception('User not found in Firestore');
      }
    } catch (e) {
      print('Error fetching user from Firestore: $e');
      throw Exception('Error fetching user from Firestore');
    }
  }

  // MENU
  Future<void> fetchMenuItems() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('menu').get();
      _menuItems = snapshot.docs.map((doc) {
        return MenuItem(
          id: doc.id,
          type: doc['type'] ?? '',
          name: doc['name'] ?? '',
          price: (doc['price'] ?? 0.0).toDouble(),
          imageUrl: doc['image'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching menu items: $e');
    }
  }

  Future<void> addMenuItem(
      String type, String name, double price, String imageFilePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('menu/$name.jpg');
      await storageRef.putFile(File(imageFilePath));
      final imageUrl = await storageRef.getDownloadURL();

      final docRef = await FirebaseFirestore.instance.collection('menu').add({
        'type': type,
        'name': name,
        'price': price,
        'image': imageUrl,
      });

      await fetchMenuItems();
    } catch (e) {
      print('Error adding menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String menuItemId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('menu')
          .doc(menuItemId)
          .get();

      if (docSnapshot.exists) {
        String imageUrl = docSnapshot['image'];

        await FirebaseFirestore.instance
            .collection('menu')
            .doc(menuItemId)
            .delete();

        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();

        await fetchMenuItems();
      }
    } catch (e) {
      print('Error deleting menu item: $e');
    }
  }

  Future<void> updateMenuItem(MenuItem menuItem, String type, String name,
      double price, String imageFilePath) async {
    try {
      String imageUrl = menuItem.imageUrl;

      if (imageFilePath.isNotEmpty) {
        final storageRef =
            FirebaseStorage.instance.ref().child('menu/$name.jpg');
        await storageRef.putFile(File(imageFilePath));
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('menu')
          .doc(menuItem.id)
          .update({
        'type': type,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
      });

      await fetchMenuItems();
    } catch (e) {
      print('Error updating menu item: $e');
    }
  }

  //CART
  Future<void> fetchCartItems() async {
    try {
      firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userID', isEqualTo: currentUser.uid)
          .get();

      _cartItems = snapshot.docs.map((doc) {
        return CartItem(
          id: doc.id,
          itemID: doc['itemID'] ?? '',
          userID: doc['userID'] ?? '',
          type: doc['type'] ?? '',
          name: doc['name'] ?? '',
          price: (doc['price'] ?? 0.0).toDouble(),
          quantity: doc['quantity'] ?? 0,
          total: (doc['total'] ?? 0.0).toDouble(),
          imageUrl: doc['image'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> addCartItem(
      String itemID,
      String userID,
      String type,
      String name,
      double price,
      int quantity,
      double total,
      String imageFilePath) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('cart').add({
        'itemID': itemID,
        'userID': userID,
        'type': type,
        'name': name,
        'price': price,
        'quantity': quantity,
        'total': total,
        'image': imageFilePath,
      });

      await fetchMenuItems();
    } catch (e) {
      print('Error adding menu item to cart: $e');
    }
  }

  Future<void> deleteCartItem(String cartItemID) async {
    try {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartItemID)
          .delete();

      await fetchCartItems();
    } catch (e) {
      print('Error deleting menu item: $e');
    }
  }

  //ORDERS
  Future<void> fetchOrders() async {
    try {
      firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      //final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('orders').get();

      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      _orderItems = snapshot.docs.map((doc) {
        // Extract data from Firestore document
        List<dynamic> cartItemsData = doc['cartItems'];
        List<CartItem> cartItems = cartItemsData.map((itemData) {
          return CartItem(
            id: itemData['id'],
            itemID: itemData['itemID'],
            userID: itemData['userID'],
            type: itemData['type'],
            name: itemData['name'],
            price: itemData['price'].toDouble(),
            quantity: itemData['quantity'],
            total: itemData['total'].toDouble(),
            imageUrl: itemData['imageUrl'],
          );
        }).toList();

        return OrderItem(
          id: doc.id,
          status: doc['status'],
          createdAt: doc['createdAt'].toDate(),
          customerID: doc['customerID'],
          customerFirstName: doc['customerFirstName'],
          customerLastName: doc['customerLastName'],
          cartTotal: doc['cartTotal'].toDouble(),
          cartItems: cartItems,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> placeOrder(List<CartItem> cartItems, double cartTotal) async {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      custom_user.User currentuserinfo = await findUser(currentUser);

      CollectionReference orders =
          FirebaseFirestore.instance.collection('orders');
      List<Map<String, dynamic>> cartItemsData =
          cartItems.map((item) => item.toMap()).toList();

      DocumentReference newOrderRef = await orders.add({
        'status': 'pending',
        'createdAt': DateTime.now(),
        'customerID': currentuserinfo.id,
        'customerFirstName': currentuserinfo.firstName,
        'customerLastName': currentuserinfo.lastName,
        'cartTotal': cartTotal,
        'cartItems': cartItemsData,
      });

      for (var item in cartItems) {
        await deleteCartItem(item.id);
      }

      print('Order placed successfully: ${newOrderRef.id}');
    } catch (e) {
      print('Failed to place order: $e');
    }
  }
}
