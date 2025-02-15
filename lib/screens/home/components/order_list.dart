import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rider_and_clerk_application/constants.dart';
import '../../../services/order_list_service.dart';
import '../../delivery/components/delivery_list.dart';
import 'order_details.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final OrderListService _orderListService = OrderListService();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _orders = [];
  final List<int> _selectedOrderIds = []; // List to track selected orders

  @override
  void initState() {
    super.initState();
    _getOrders();
  }

  Future<void> _getOrders() async {
    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No authentication token found.";
      });
      return;
    }

    try {
      List<dynamic> items = await _orderListService.fetchOrders(token);

      // ORDERS THAT ARE PENDING
      List<dynamic> pendingOrders =
          items.where((order) => order['status'] == 0).toList();

      setState(() {
        _orders = pendingOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load orders.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _orders.isEmpty
                  ? const Center(child: Text("No orders available"))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final customer = order['customer'];
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Order #${order['id']}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Checkbox(
                                            value: _selectedOrderIds
                                                .contains(order['id']),
                                            onChanged: (bool? selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  _selectedOrderIds
                                                      .add(order['id']);
                                                } else {
                                                  _selectedOrderIds
                                                      .remove(order['id']);
                                                }
                                              });
                                            },
                                            activeColor: kPrimaryColor,
                                            checkColor: Colors.white,
                                          )
                                        ],
                                      ),
                                      const Divider(
                                          thickness: 1, color: Colors.grey),
                                      Text(
                                        "Customer: ${customer['first_name']} ${customer['last_name']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                          "Phone: ${customer['phone_number']}"),
                                      Text("Address: ${customer['address']}"),
                                      const Divider(
                                          thickness: 1, color: Colors.grey),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Order Details:",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
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
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            order['order_details'].length,
                                        itemBuilder: (context, itemIndex) {
                                          final item =
                                              order['order_details'][itemIndex];
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${int.parse(double.parse(item['quantity']).toStringAsFixed(0))} × ${item['product']['name']}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "₱${item['product']['price']}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const Divider(
                                          thickness: 1, color: Colors.grey),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderDetails(order: order),
                                              ),
                                            );
                                          },
                                          child: const Text('View Details'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_selectedOrderIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Filter the selected orders using _selectedOrderIds
                                  final selectedOrders = _orders.where((order) {
                                    return _selectedOrderIds
                                        .contains(order['id']);
                                  }).toList();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeliveryList(
                                        selectedOrders: _selectedOrderIds
                                            .map((orderId) =>
                                                _orders.firstWhere((order) =>
                                                    order['id'] == orderId))
                                            .toList()
                                            .cast<Map<String, dynamic>>(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Add to Queue'),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}
