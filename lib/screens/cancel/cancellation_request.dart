import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/screens/cancel/components/cancellation_list.dart';

class CancellationRequestScreen extends StatelessWidget {
  const CancellationRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cancellation List', style: TextStyle(fontSize: 18)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
      children: [
        Expanded(child: CancellationList())
      ]),
    );
  }
}