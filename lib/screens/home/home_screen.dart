import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/screens/home/components/order_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Orders'),
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: OrderList(), 
          ),
        ],
      ),
    );
  }
}
