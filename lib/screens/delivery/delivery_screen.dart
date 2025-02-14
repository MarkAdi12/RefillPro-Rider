import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/delivery/components/delivery_list.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key}); // No need for selectedIndex

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery List', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: DeliveryList(), // Directly use PendingList
    );
  }
}