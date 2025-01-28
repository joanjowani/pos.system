import 'package:flutter/material.dart';
import 'package:ordering_system/screens/customer/customer_cart_screen.dart';
import 'package:ordering_system/screens/customer/customer_menu_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  static const String route = '/customerhome';

  static const String name = 'CustomerHomeScreen';
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    CustomerMenuScreen(),
    CustomerCartScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Order',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}