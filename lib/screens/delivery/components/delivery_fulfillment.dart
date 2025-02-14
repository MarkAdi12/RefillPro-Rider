import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/components/custom_appbar.dart';
import 'delivery_arrive.dart';

class DeliveryFulfillmentScreen extends StatelessWidget {
  const DeliveryFulfillmentScreen({super.key});


  final List<Map<String, String>> orderDetails = const [
    {'orderID': '121884'},
    {'orderName': 'Lodi Cakes'},
    {'orderAddress': '321 Apols St. Valenzuela'},
    {'orderCreated': '7:35 AM'},
    {'orderContact': '09314232398'},
    {'paymentMethod': 'Cash on Delivery'},
  ];

  final List<Map<String, dynamic>> orderSummary = const [
    {'name': 'Round Gallon', 'quantity': 2, 'price': '60.00'},
    {'name': 'Slim Gallon', 'quantity': 1, 'price': '30.00'},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Delivery Fulfillment'),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
          height: 270,
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
          child: Center(child: Text('Map Placeholder')),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            // ORDER DETAILS
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order ID:", style: const TextStyle(fontSize: 14)),
              Text("${orderDetails[0]['orderID']}",
                  style: const TextStyle(fontSize: 17)),
              Divider(thickness: 1, color: Colors.grey[300]),
              Text("Address:", style: const TextStyle(fontSize: 14)),
              Text("${orderDetails[2]['orderAddress']}",
                  style: const TextStyle(fontSize: 17)),
              Text("Phone Number:", style: const TextStyle(fontSize: 14)),
              Text("${orderDetails[4]['orderContact']}",
                  style: const TextStyle(fontSize: 17)),
              Text("Customer Name: ", style: const TextStyle(fontSize: 14)),
              Text("${orderDetails[1]['orderName']}",
                  style: const TextStyle(fontSize: 17)),
              Text("Payment Method:", style: const TextStyle(fontSize: 14)),
              Text("${orderDetails[5]['paymentMethod']}",
                  style: const TextStyle(fontSize: 17)),
              Text('Cash To Collect', style: const TextStyle(fontSize: 16)),
              Text('₱90.00',
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'arial',
                      fontWeight: FontWeight.bold)),
              Divider(thickness: 1, color: Colors.grey[300]),
              Text("Order Summary:", style: const TextStyle(fontSize: 17)),
              ...orderSummary.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name'], style: const TextStyle(fontSize: 16)),
                    Text("${item['quantity']} x ${item['price']}",
                        style: const TextStyle(fontSize: 16)),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ])),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),

          ),
          
          child: ElevatedButton(
            onPressed: () {
              FeedbackWidget.ArriveatAddressDialog(context);
            },
            child:
                const Text('Arrive At Address', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
