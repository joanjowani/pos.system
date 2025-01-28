import 'package:flutter/material.dart';
import 'package:ordering_system/screens/admin/admin_menu_screen.dart';
import 'package:ordering_system/screens/admin/admin_register_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String route = '/adminhome';

  static const String name = 'AdminHomeScreen';
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
   int _selectedIndex = 0;

  static const List<Widget> _screens = [
    AdminMenuScreen(),
    AdminRegisterScreen(),
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
            icon: Icon(Icons.menu, size: 30,),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30,),
            label: 'Register',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}