import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/components/custom_appbar.dart';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/init_screen.dart';

class CancellationDetails extends StatelessWidget {
  const CancellationDetails({super.key});

  final List<Map<String, String>> orderDetails = const [
    {'orderID': '121884'},
    {'orderName': 'Lebron'},
    {'orderAddress': '321 Los Angeles St. Valenzuela'},
    {'orderCreated': '7:35 AM'},
    {'orderContact': '09314232398'},
    {'paymentMethod': 'Cash on Delivery'},
    {'cancellationReason': 'Change Of Mind'},
  ];

  final List<Map<String, dynamic>> orderSummary = const [
    {'name': 'Round Gallon', 'quantity': 2, 'price': '60.00'},
    {'name': 'Slim Gallon', 'quantity': 1, 'price': '30.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cancellation Details'),
      body: Container(
        height: 500,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order ID:",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Ordered at:",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${orderDetails[0]['orderID']}",
                  style: const TextStyle(fontSize: 22),
                ),
                Text(
                  "${orderDetails[3]['orderCreated']}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            Text(
              "Customer Name: ",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "${orderDetails[1]['orderName']}",
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              "Address:",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "${orderDetails[2]['orderAddress']}",
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              "Phone Number:",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "${orderDetails[4]['orderContact']}",
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              "Payment Method:",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "${orderDetails[5]['paymentMethod']}",
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              "Cancellation Reason:",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "${orderDetails[6]['cancellationReason']}",
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            Text(
              "Order Summary:",
              style: const TextStyle(fontSize: 17),
            ),
            ...orderSummary.map((item) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${item['quantity']} x ${item['price']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            Divider(thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Confirmation Successful!',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'View More Cancellation request?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InitScreen(),
                                  ));
                            },
                            child: const Text(
                              'No',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => InitScreen(initialIndex: 3)));
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 16,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
                child: const Text("Approve Cancellation"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
