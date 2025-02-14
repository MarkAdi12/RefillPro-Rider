import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/components/custom_appbar.dart';
import 'package:rider_and_clerk_application/screens/delivery/components/delivery_fulfillment.dart';

class DeliveryDetails extends StatelessWidget {
  const DeliveryDetails({super.key});

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
      appBar: CustomAppBar(title: 'Delivery Details'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildOrderInfo(),
              const SizedBox(height: 16),
              _buildLocationMap(),
              const SizedBox(height: 16),
              _buildOrderSummary(),
              const SizedBox(height: 16),
              _buildCashToCollect(),
              const SizedBox(height: 16),
              _buildStartDeliveryButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Order ID:", style: _labelStyle),
            Text("Ordered at:", style: _labelStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${orderDetails[0]['orderID']}", style: _valueStyle),
            Text("${orderDetails[3]['orderCreated']}", style: _valueStyle),
          ],
        ),
        const Divider(thickness: 1, color: Colors.grey),
        _buildDetailRow("Customer Name:", "${orderDetails[1]['orderName']}"),
        _buildDetailRow("Address:", "${orderDetails[2]['orderAddress']}"),
        _buildDetailRow("Phone Number:", "${orderDetails[4]['orderContact']}"),
        _buildDetailRow("Payment Method:", "${orderDetails[5]['paymentMethod']}"),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        Text(value, style: _valueStyle),
      ],
    );
  }

  Widget _buildLocationMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location On Map:", style: _headerStyle),
        const SizedBox(height: 4),
        Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text('Map Placeholder')),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Order Summary:", style: _headerStyle),
        ...orderSummary.map((item) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['name'], style: _valueStyle),
              Text("${item['quantity']} x ${item['price']}", style: _valueStyle),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCashToCollect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Cash To Collect', style: _valueStyle),
        Text('₱90.00', style: _cashStyle),
      ],
    );
  }

  Widget _buildStartDeliveryButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DeliveryFulfillmentScreen()),
          );
        },
        child: const Text('Start Delivery', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(fontSize: 14);
  TextStyle get _valueStyle => const TextStyle(fontSize: 17);
  TextStyle get _headerStyle => const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle get _cashStyle => const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
}