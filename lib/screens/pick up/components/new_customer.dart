// ignore_for_file: unused_field, unused_local_variable

import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/components/custom_appbar.dart';

class NewCustomerScreen extends StatelessWidget {
  NewCustomerScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    
    // STATIC VALUES
    String? newCustomerName; 
    String? newCustomerAddress; 

    return Scaffold(
      appBar: CustomAppBar(title: 'New Customer'),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    'Customer Registration',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // CUSTOMER NAME
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      newCustomerName =
                          value; 
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the customer name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // CUSTOMER ADDRESS
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Customer Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      newCustomerAddress =
                          value; 
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the customer address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // ADD CUSTOMER BUTTON
                  ElevatedButton(
                    onPressed: () {
                      // VALIDATE FORM
                      if (_formKey.currentState?.validate() ?? false) {
                        // BACKEND
                      }
                    },
                    child: const Text('Add Customer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
