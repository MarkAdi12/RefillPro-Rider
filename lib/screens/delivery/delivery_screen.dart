import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/order_service.dart';
import 'components/delivery_fulfillment.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<Map<String, dynamic>> _sortedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedOrders();
  }

  Future<void> _loadSavedOrders() async {
    List<Map<String, dynamic>> loadedOrders =
        await OrderService.loadSavedOrders();
    setState(() {
      _sortedOrders = loadedOrders;
      _isLoading = false;
    });

    if (_sortedOrders.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No saved orders found.')));
    }
  }

  Future<void> _removeOrder(int orderId) async {
    // Remove the selected order from SharedPreferences
    List<Map<String, dynamic>> updatedOrders =
        List.from(_sortedOrders); // Create a copy of the list
    updatedOrders.removeWhere((order) => order['id'] == orderId);

    // Update SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_list', jsonEncode(updatedOrders));

    // Update the UI list
    setState(() {
      _sortedOrders = updatedOrders; // Only update with the modified list
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_sortedOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Delivery List', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Text('No orders available.', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Sorted Delivery List', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: _sortedOrders.length,
        itemBuilder: (context, index) {
          final order = _sortedOrders[index];
          String orderId = order['id'].toString();
          String address =
              order['customer']['address'] ?? 'No Address Available';
          double totalPrice = 0.0;
          if (order['order_details'] is List) {
            for (var detail in order['order_details']) {
              totalPrice += double.tryParse(detail['total_price']) ?? 0.0;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
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
                  // Order ID and spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #$orderId",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _removeOrder(order[
                              'id']); // Call the remove function with the correct order ID
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
            
                  // Customer information
                  Text(
                    "Customer: ${order['customer']['first_name']} ${order['customer']['last_name']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text("Phone: ${order['customer']['phone_number']}"),
                  Text("Address: ${order['customer']['address']}"),
                  const Divider(thickness: 1, color: Colors.grey),
            
                  // Order details title and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Order Details:",
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Price",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
            
                  // Order items list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order['order_details'].length,
                    itemBuilder: (context, itemIndex) {
                      final item = order['order_details'][itemIndex];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${int.parse(double.parse(item['quantity']).toStringAsFixed(0))} × ${item['product']['name']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "₱${item['product']['price']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
            
                  // View details button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryFulfillment(order: order),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
