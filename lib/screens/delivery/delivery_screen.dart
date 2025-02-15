import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../home/components/google_maps.dart';
// Import the GoogleMapScreen

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  int _currentOrderIndex = 0;
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
          title: Text('Delivery Fulfillment', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
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
      ),
      body: ListView.builder(
        itemCount: _sortedOrders.length,
        itemBuilder: (context, index) {
          final order = _sortedOrders[index];
          String orderId = order['id'].toString();
          String address = order['customer']['address'] ?? 'No Address Available';
          double totalPrice = order['total_price']?.toDouble() ?? 0.0;

          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  title: Text('Order ID: $orderId'),
                  subtitle: Text('Address: $address\nTotal Price: PHP ${totalPrice.toStringAsFixed(2)}'),
                  onTap: () {
                    // Handle order tap (optional action when tapping on the order)
                  },
                ),
                // Button to navigate to GoogleMapScreen for each order
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Pass the selected order to GoogleMapScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoogleMapScreen(order: order),
                        ),
                      );
                    },
                    child: Text('Navigate to Delivery Location'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
