import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../services/order_service.dart';
import 'components/delivery_fulfillment.dart';
import '../../../../../services/order_management_service.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<Map<String, dynamic>> _sortedOrders = [];
  bool _isLoading = true;
  bool _isPressed = false;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _updateOrderStatusInFirebase(String orderId, int status,
      {int? riderId, double? riderLat, double? riderLong}) async {
    Map<String, dynamic> updates = {
      'status': status,
    };

    if (status == 3 &&
        riderId != null &&
        riderLat != null &&
        riderLong != null) {
      updates.addAll({
        'riderId': riderId,
        'riderLat': riderLat,
        'riderLong': riderLong,
      });
    }

    await _database.child('orders/$orderId').update(updates);

    print(
        'Order $orderId updated - Status: $status, Rider ID: $riderId, Location: ($riderLat, $riderLong)');
  }

  @override
  void initState() {
    super.initState();
    _loadSavedOrders();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)!.addScopedWillPopCallback(() async {
        _loadSavedOrders();
        return true;
      });
    });
  }

  Future<void> _loadSavedOrders() async {
    List<Map<String, dynamic>> loadedOrders =
        await SavedOrders.loadSavedOrders();
    setState(() {
      _sortedOrders = loadedOrders;
      _isLoading = false;
    });
  }

  Future<bool> _showWarningDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Warning',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              content: const Text(
                'This is not the next order in the queue. Proceeding may affect delivery efficiency. Continue?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirm
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        ) ??
        false;
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

  Future<void> _removeCancelledOrder(int orderId) async {
    // Remove from _sortedOrders (delivery_list)
    List<Map<String, dynamic>> updatedDeliveryOrders = List.from(_sortedOrders);
    updatedDeliveryOrders.removeWhere((order) => order['id'] == orderId);

    // Update SharedPreferences for delivery_list
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_list', jsonEncode(updatedDeliveryOrders));

    // Remove from pending_list
    String? pendingListJson = prefs.getString('pending_list');
    if (pendingListJson != null) {
      List<dynamic> pendingOrders = jsonDecode(pendingListJson);
      pendingOrders.removeWhere((order) => order['id'] == orderId);

      // Update SharedPreferences for pending_list
      await prefs.setString('pending_list', jsonEncode(pendingOrders));
    }

    // Update the UI list
    setState(() {
      _sortedOrders = updatedDeliveryOrders;
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
            onPressed: _removeAllOrders,
            icon: Icon(Icons.delete, color: Colors.white),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "Order #$orderId",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
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
                                  "${int.parse(double.parse(item['quantity']).toStringAsFixed(0))} × "
                                  "${item['product']['name'].length > 30 ? item['product']['name'].substring(0, 30) + '...' : item['product']['name']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "PHP ${item['total_price']}",
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
                              "PHP ${totalPrice.toStringAsFixed(2)}",
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
                            onPressed: _isPressed
                                ? null
                                : () async {
                                    setState(() {
                                      _isPressed = true;
                                    });

                                    final String? token = await _secureStorage
                                        .read(key: 'access_token');
                                    if (token == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Access token not found. Please log in again.'),
                                        ),
                                      );
                                      setState(() {
                                        _isPressed = false;
                                      });
                                      return;
                                    }

                                    int orderId = order['id'];

                                    // Ensure orders are loaded
                                    if (_sortedOrders.isNotEmpty &&
                                        _sortedOrders.first['id'] != orderId) {
                                      bool proceed =
                                          await _showWarningDialog(context);
                                      if (!proceed) {
                                        setState(() {
                                          _isPressed = false;
                                        });
                                        return; // Stop execution if the user cancels
                                      }
                                    }

                                    // Proceed with updating the order status
                                    try {
                                      DateTime deliveryDateTime =
                                          DateTime.now();
                                      int newStatus =
                                          order['status'] == 2 ? 3 : 3;

                                      final orders = await OrderService()
                                          .fetchOrders(token);
                                      final orderDetails = orders.firstWhere(
                                        (o) => o['id'] == orderId,
                                        orElse: () => null,
                                      );

                                      if (orderDetails != null &&
                                          orderDetails['status'] > 4) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Order Cancelled',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              content: Text(
                                                'The order has been cancelled.\nPlease proceed to the next order.',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _removeCancelledOrder(
                                                        orderId);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        setState(() {
                                          _isPressed = false;
                                        });
                                        return;
                                      }

                                      bool isUpdated =
                                          await OrderService().updateOrder(
                                        token,
                                        orderId,
                                        deliveryDateTime,
                                        newStatus,
                                      );

                                      if (isUpdated) {
                                        await _updateOrderStatusInFirebase(
                                            orderId.toString(), newStatus);
                                        setState(() {
                                          order['status'] = newStatus;
                                        });

                                        if (newStatus == 3 || newStatus == 2) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DeliveryFulfillment(
                                                      order: order),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Failed to update order. Please try again.'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error fetching order details: $e'),
                                        ),
                                      );
                                    }

                                    setState(() {
                                      _isPressed = false;
                                    });
                                  },
                            child: _isPressed
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(order['status'] == 2
                                    ? 'Reattempt Delivery'
                                    : 'Start Delivery'),
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
