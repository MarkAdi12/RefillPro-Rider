import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_and_clerk_application/components/custom_appbar.dart';
import 'package:rider_and_clerk_application/constants.dart';

import '../../delivery/components/delivery_fulfillment.dart';

class OrderDetails extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Order Details'),
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
              const SizedBox(height: 12),
              _buildLocationContainer(
                  context), 
              const SizedBox(height: 12),
              _buildOrderSummary(), 
              const SizedBox(height: 12),
              _buildConfirmButton(context),
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
            Text("${order['id']}", style: _valueStyle),
            Text("${order['created_at'] ?? 'N/A'}", style: _valueStyle),
          ],
        ),
        Divider(thickness: 1, color: Colors.grey[600]),
        _buildDetailRow("Customer Name:",
            "${order['customer']['first_name']} ${order['customer']['last_name']}"),
        _buildDetailRow("Address:", "${order['customer']['address']}"),
        _buildDetailRow(
            "Phone Number:", "${order['customer']['phone_number']}"),
        Row(
          children: [
            _buildDetailRow("Payment Method:", "${order['payment_method']}"),
            Spacer(),
            if (order['payment_method'] == 'Online Payment')
              _buildProofOfPaymentButton(),
          ],
        ),
        if (order['remarks'] != null &&
            order['remarks'].toString().trim().isNotEmpty) ...[
          Text("Remarks:", style: _valueStyle),
          Text(order['remarks'], style: _valueStyle),
        ],
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

  Widget _buildOrderSummary() {
    double totalPrice = order['order_details'].isNotEmpty
        ? order['order_details']
            .map<double>((item) => double.parse(item['total_price']))
            .fold(0.0, (a, b) => a + b)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Order Summary:", style: _headerStyle),
        ...order['order_details'].map<Widget>((item) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${int.parse(double.parse(item['quantity']).toStringAsFixed(0))} × ${item['product']['name']}",
                style: _valueStyle,
              ),
              Text("PHP ${item['total_price']}", style: _valueStyle),
            ],
          );
        }).toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cash To Collect', style: _valueStyle),
            Text('PHP ${totalPrice.toStringAsFixed(2)}', style: _valueStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationContainer(BuildContext context) {
    double latitude = double.tryParse(order['customer']['lat'] ?? '0') ?? 0.0;
    double longitude = double.tryParse(order['customer']['long'] ?? '0') ?? 0.0;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId("customer_location"),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: "Customer's Location",
                snippet: order['customer']['address'],
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildProofOfPaymentButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _showProofOfPaymentDialog();
        },
        child: Icon(Icons.photo_size_select_actual,
            size: 28, color: kPrimaryColor),
      ),
    );
  }

  void _showProofOfPaymentDialog() {}

  Widget _buildConfirmButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeliveryFulfillment(order: order)),
          );
        },
        child:
            const Text('View Location on Map', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(fontSize: 14);
  TextStyle get _valueStyle => const TextStyle(fontSize: 17);
  TextStyle get _headerStyle =>
      const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
}


