import 'package:flutter/material.dart';

class RefillScreen extends StatelessWidget {
  const RefillScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final formKey = GlobalKey<FormState>();

    // STATIC VALUESSSS
    String? selectedSaleType; 
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
              key: formKey, // FORMKEY
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TITLE 
                  Text(
                    'Refill Order',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // TYPE OF SALE OPTION
                  DropdownButtonFormField<String>(
                    value: selectedSaleType, // SELECTED TYPE OF SALE
                    decoration: InputDecoration(
                      labelText: 'Type of Sale',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: "Refill Only",
                        child: Text("Refill Only"),
                      ),
                      DropdownMenuItem<String>(
                        value: "Returned Container",
                        child: Text("Returned Container"),
                      ),
                      DropdownMenuItem<String>(
                        value: "Borrowed Container",
                        child: Text("Borrowed Container"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      // NEW SELECTED TYPE OF SALE
                      selectedSaleType = newValue;
                    },
                  ),
                  const SizedBox(height: 16),

                  // TYPE OF CONTAINER OPTION
                  DropdownButtonFormField<String>(
                    value: selectedContainer, // SELECTED CONTAINER
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
                       DropdownMenuItem<String>(
                        value: "Other Container",
                        child: Text("Other Container"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      // NEW SELECTED CONTAINER
                      selectedContainer = newValue;
                    },
                  ),
                  const SizedBox(height: 12),

                  // QUANTITY SECTION
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
                              // DECREASE QUANTITY
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
                              // INCREASE QUANTITY
                              quantity++;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // AMOUNT SECTION
                  TextFormField(
                    initialValue:
                        amount.toStringAsFixed(2), // DEFAULT AMOUNT
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      amount = double.tryParse(value) ?? amount;
                    },
                  ),
                  const SizedBox(height: 20),

                  // CREATE ORDER BUTTON
                  ElevatedButton(
                    onPressed: () {
                        // BACKEND 
                    },
                    child: const Text('Generate Order'),
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
