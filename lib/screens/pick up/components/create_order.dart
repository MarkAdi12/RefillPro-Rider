// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/pick%20up/components/new_customer.dart';

class CreateOrder extends StatelessWidget {
  const CreateOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    // STATIC VALUES
    String? userName;
    String? userAddress;
    String? selectedContainer;
    int quantity = 1;
    double amount = 30.00;

    return Scaffold(
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
              key: _formKey, // Assign the form key
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Create Order',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // User Name Input
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      userName = value; // Update userName based on input
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // User Address Input
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Customer Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      userAddress = value; // Update userAddress based on input
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address.';
                      }
                      return null;
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewCustomerScreen()),
                          );
                        },
                        child: Text(
                          'New Customer?',
                          style: TextStyle(color: kPrimaryColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  // Container Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedContainer, // Current selected value
                    decoration: InputDecoration(
                      labelText: 'Container',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: "Slim Gallon",
                        child: Text("Slim Gallon"),
                      ),
                      DropdownMenuItem<String>(
                        value: "Round Gallon",
                        child: Text("Round Gallon"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      // Update the selected container
                      selectedContainer = newValue;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a container.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              // Decrease quantity, ensuring it doesn't go below 1
                              if (quantity > 1) {
                                quantity--;
                              }
                            },
                          ),
                          Text('$quantity',
                              style: const TextStyle(fontSize: 17)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              // Increase quantity
                              quantity++;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  TextFormField(
                    initialValue:
                        amount.toStringAsFixed(2), // Display initial amount
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Update amount based on user input
                      amount = double.tryParse(value) ?? amount;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount.';
                      }
                      final parsedValue = double.tryParse(value);
                      if (parsedValue == null || parsedValue <= 0) {
                        return 'Please enter a valid amount.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Create Order Button
                  ElevatedButton(
                    onPressed: () {
                      // Validate the form
                      if (_formKey.currentState?.validate() ?? false) {
                        // TODO: Implement order creation logic
                        // This is where you would call your backend API to create the order
                        // You can use userName, selectedContainer, quantity, and amount
                      }
                    },
                    child: const Text('Create Order'),
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
