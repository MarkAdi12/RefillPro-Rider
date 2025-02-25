import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../services/order_management_service.dart';
import 'components/nna_delivery.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final OrderService _orderListService = OrderService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _orders = [];
  final List<int> _selectedOrderIds = [];

  @override
  void initState() {
    super.initState();
    _loadPendingOrders(); // Load orders from pending_list when the screen initializes
  }

  Future<List<dynamic>> _getFilteredPendingOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load pending_list
    String? pendingOrdersJson = prefs.getString('pending_list');
    List<dynamic> pendingOrders =
        pendingOrdersJson != null ? jsonDecode(pendingOrdersJson) : [];

    // Load delivery_list
    String? deliveryOrdersJson = prefs.getString('delivery_list');
    List<dynamic> deliveryOrders =
        deliveryOrdersJson != null ? jsonDecode(deliveryOrdersJson) : [];

    // Filter out orders that are already in delivery_list
    List<dynamic> filteredOrders = pendingOrders.where((pendingOrder) {
      return !deliveryOrders
          .any((deliveryOrder) => deliveryOrder['id'] == pendingOrder['id']);
    }).toList();

    return filteredOrders;
  }

  // Load orders from pending_list
  Future<void> _loadPendingOrders() async {
    List<dynamic> filteredOrders = await _getFilteredPendingOrders();

    setState(() {
      _orders = filteredOrders;
      _isLoading = false;
    });

    // If no filtered orders are available, fetch new orders from the API
    if (filteredOrders.isEmpty) {
      _getOrders();
    }
  }

  // Save orders to pending_list
  Future<void> _savePendingList(List<dynamic> orders) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ordersJson = jsonEncode(orders);
    await prefs.setString('pending_list', ordersJson);
  }

  // Check if an order is already saved in delivery_list
  Future<bool> _isOrderSaved(int orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDeliveriesJson = prefs.getString('delivery_list');
    if (savedDeliveriesJson != null) {
      List<dynamic> savedDeliveries = jsonDecode(savedDeliveriesJson);
      return savedDeliveries.any((order) => order['id'] == orderId);
    }
    return false;
  }

  // Fetch orders from the API
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
      List<dynamic> pendingOrders = items
          .where((order) => order['status'] == 0 || order['status'] == 1)
          .toList();

      // Filter out orders that are already in delivery_list
      List<dynamic> filteredOrders = await _getFilteredPendingOrders();
      filteredOrders.addAll(pendingOrders.where((order) {
        return !filteredOrders
            .any((filteredOrder) => filteredOrder['id'] == order['id']);
      }));

      // Save the filtered orders to pending_list
      await _savePendingList(filteredOrders);

      setState(() {
        _orders = filteredOrders;
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
      appBar: AppBar(
        title: Text('Pending Orders'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _getOrders(); // Refresh orders
            },
            icon: Icon(Icons.refresh),
            iconSize: 26,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: Text('Loading...'))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _orders.isEmpty
                  ? const Center(child: Text("No orders available"))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (_selectedOrderIds.length ==
                                        (_orders.length <= 20
                                            ? _orders.length
                                            : 20)) {
                                      _selectedOrderIds.clear();
                                    } else {
                                      _selectedOrderIds.clear();
                                      _selectedOrderIds.addAll(_orders
                                          .sublist(
                                              0,
                                              _orders.length <= 20
                                                  ? _orders.length
                                                  : 20)
                                          .map((order) => order['id']));
                                    }
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedOrderIds.length ==
                                              (_orders.length <= 20
                                                  ? _orders.length
                                                  : 20)
                                          ? "Deselect All"
                                          : (_orders.length <= 20
                                              ? "Select All"
                                              : "Select 20 Orders"),
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _selectedOrderIds.length ==
                                              (_orders.length <= 20
                                                  ? _orders.length
                                                  : 20)
                                          ? Icons.check_box_rounded
                                          : Icons.check_box_outline_blank,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final customer = order['customer'];
                                double totalPrice = order['order_details']
                                    .map((item) =>
                                        double.parse(item['total_price']))
                                    .fold(0.0, (prev, amount) => prev + amount);
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 16),
                                        decoration: const BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Order No: ${order['id']}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
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
                                              activeColor: Colors.white,
                                              checkColor: kPrimaryColor,
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                  255, 122, 122, 122),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(16)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${customer['first_name']} ${customer['last_name']}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            Text("${customer['phone_number']}"),
                                            Text(
                                              "${customer['address']}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Divider(),
                                            // Product List
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  order['order_details'].length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    order['order_details']
                                                        [index];
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Total",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  "₱${totalPrice.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
