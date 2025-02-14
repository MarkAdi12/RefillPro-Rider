import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/screens/home/components/inventory_status.dart';
import 'package:rider_and_clerk_application/screens/home/components/order_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order List'),
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InventoryStatus(), // Ensure this widget is displayed

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 1, color: Colors.grey[300]),
          ),

          Expanded(
            child: OrderList(), // This will take the remaining space
          ),
        ],
      ),
    );
  }
}
