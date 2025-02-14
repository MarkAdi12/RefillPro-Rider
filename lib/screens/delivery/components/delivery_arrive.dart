import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/init_screen.dart';

final List<Map<String, dynamic>> orderSummary = const [
  {'name': 'Round Gallon', 'quantity': 2, 'price': '60.00'},
  {'name': 'Slim Gallon', 'quantity': 1, 'price': '30.00'},
];

class FeedbackWidget {
  static void ArriveatAddressDialog(BuildContext context) {
    // SAMPLE TEXTFIELD CONTROLLER
    final TextEditingController borrowedController = TextEditingController();
    final TextEditingController returnedController = TextEditingController();
    final TextEditingController destroyedController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
            title: const Center(
            child: Text(
              "Container Inputation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 1000,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IINPUT LABELS 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Borrowed",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Returned",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Destroyed",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10), // Add some space

                  // INPUT FIELDS FPR CONTAINER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputField(borrowedController, "0"),
                      _buildInputField(returnedController, "3"),
                      _buildInputField(destroyedController, "0"),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ORDER DETAILS
                  Text("Order Summary:", style: const TextStyle(fontSize: 17)),
                  ...orderSummary.map((item) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name'],
                            style: const TextStyle(fontSize: 16)),
                        Text("${item['quantity']} x ${item['price']}",
                            style: const TextStyle(fontSize: 16)),
                      ],
                    );
                  }),

                  // CASH TO COLLEECT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Cash to Collect",
                          style: const TextStyle(fontSize: 17)),
                      Text("90.00", style: const TextStyle(fontSize: 17)),
                    ],
                  ),
                  Divider(thickness: 1, color: Colors.grey[500]),

                  ElevatedButton(
                    onPressed: () {
                    // FAILED DELIVERY BACKEND HERE
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, 
                    ),
                    child: const Text(
                      'Failed Delivery',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                     // COMPLETE DELIVERY BACKEND HERE
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InitScreen(initialIndex: 1,),)); // SAMPLE ONLY
                    },
                    child: const Text(
                      'Complete Delivery',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Optionally, you can handle form submission here
                // For example, send data to the backend
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build input fields
  static Widget _buildInputField(
      TextEditingController controller, String hint) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}
