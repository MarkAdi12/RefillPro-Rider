import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
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

  Future<void> _removeAllOrders() async {
    // Clear the list
    List<Map<String, dynamic>> updatedOrders = [];

    // Update SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_list', jsonEncode(updatedOrders));

    // Update the UI
    setState(() {
      _sortedOrders = updatedOrders;
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
        title: Text('Delivery List', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _removeAllOrders, // Call the function correctly
            icon: Icon(Icons.delete,
                color: Colors.white), // Use Icon widget properly
          ),
        ],
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order #$orderId",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.highlight_remove_outlined),
                          onPressed: () {
                            _removeOrder(order['id']);
                          },
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 122, 122, 122),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customer: ${order['customer']['first_name']} ${order['customer']['last_name']}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text("Phone: ${order['customer']['phone_number']}"),
                        Text(
                          "${order['customer']['address']}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(),
                        // Product List
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
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              "₱${totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
