import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/screens/reports/components/report_card.dart';
import 'package:rider_and_clerk_application/screens/settings/settings_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Daily Reports'),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(),));
        }, 
        icon: Icon(Icons.settings))
        ],
      ),
      body: SingleChildScrollView( 
        child: Column(
          children: [
      
          ],
        ),
      ),
    );
  }
}