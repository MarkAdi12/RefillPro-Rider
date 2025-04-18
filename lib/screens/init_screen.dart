import 'package:rider_and_clerk_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/screens/delivery/delivery_screen.dart';
import 'package:rider_and_clerk_application/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class InitScreen extends StatefulWidget {
  final int initialIndex;
  const InitScreen({super.key, this.initialIndex = 0});
  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  late int currentSelectedIndex;
  List<Map<String, dynamic>> sortedOrders = [];

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = widget.initialIndex;
    _loadSavedDeliveries();
  }

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  Future<void> _loadSavedDeliveries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedOrders = prefs.getString('delivery_list');
    if (savedOrders != null) {
      setState(() {
        sortedOrders = List<Map<String, dynamic>>.from(jsonDecode(savedOrders));
      });
    }
  }

  final List<Widget> pages = [
    HomeScreen(),
    DeliveryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: inActiveIconColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined, size: 22),
            activeIcon: Icon(Icons.store_rounded, size: 26),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined, size: 22),
            activeIcon: Icon(Icons.delivery_dining, size: 26),
            label: "Delivery",
          ),
        ],
      ),
    );
  }
}
