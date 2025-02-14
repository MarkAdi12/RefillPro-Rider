import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const GoogleMapScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Customer location
    double customerLatitude =
        double.tryParse(order['customer']['lat'] ?? '0') ?? 0.0;
    double customerLongitude =
        double.tryParse(order['customer']['long'] ?? '0') ?? 0.0;

    // Rider location
    double riderLatitude =
        double.tryParse(order['assigned_to']['lat'] ?? '0') ?? 0.0;
    double riderLongitude =
        double.tryParse(order['assigned_to']['long'] ?? '0') ?? 0.0;

    double totalPrice = 0.0;
    order['order_details'].forEach((orderDetail) {
      totalPrice += double.tryParse(orderDetail['total_price'] ?? '0.0') ?? 0.0;
    });

    return Scaffold(
      appBar: AppBar(title: Text("Delivery")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Google Map
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(riderLatitude, riderLongitude),
                  zoom: 18,
                ),
                markers: {
                  // Customer marker
                  Marker(
                    markerId: MarkerId("customer_location"),
                    position: LatLng(customerLatitude, customerLongitude),
                    infoWindow: InfoWindow(
                      title: "Customer's Location",
                      snippet: order['customer']['address'],
                    ),
                  ),
                  // Rider marker
                  Marker(
                    markerId: MarkerId("rider_location"),
                    position: LatLng(riderLatitude, riderLongitude),
                    infoWindow: InfoWindow(
                      title: "Rider's Location",
                      snippet: order['assigned_to']['address'],
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet), 
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Customer info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID:', style: TextStyle(fontSize: 16)),
                      Text('${order['id']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address:', style: TextStyle(fontSize: 14)),
                      Text('${order['customer']['address']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone Number:', style: TextStyle(fontSize: 14)),
                      Text('${order['customer']['phone_number']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name:', style: TextStyle(fontSize: 14)),
                      Text(
                          '${order['customer']['first_name']} ${order['customer']['last_name']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text('Delivery Instruction:', style: TextStyle(fontSize: 14)),
                  Text(
                      '${order['remarks']?.isNotEmpty ?? false ? order['remarks'] : "None"}',
                      style: TextStyle(fontSize: 16)),
                  Divider(),

                  // Order Summary
                  Text('Order Summary', style: TextStyle(fontSize: 16)),
                  Column(
                    children: order['order_details'].map<Widget>((orderDetail) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${orderDetail['quantity']} x ${orderDetail['product']['name']}'),
                          Text('${orderDetail['total_price']}'),
                        ],
                      );
                    }).toList(),
                  ),

                  // Cash to Collect and Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cash to Collect:'),
                      Text('PHP ${totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price:'),
                      Text('PHP ${totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Buttons for completing or failing the delivery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            // Add functionality for complete delivery here
                          },
                          child: Text('Complete Delivery'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () {},
                          child: Text('Failed Delivery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
