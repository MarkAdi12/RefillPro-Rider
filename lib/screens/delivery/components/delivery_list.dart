import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/init_screen.dart';
import '../delivery_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryList extends StatefulWidget {
  final List<Map<String, dynamic>> selectedOrders;

  DeliveryList({required this.selectedOrders});

  @override
  _DeliveryListState createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final String googleMapsApiKey = 'AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk';
  final double storeLat = 14.7168122;
  final double storeLon = 120.9553401;
  List<Map<String, dynamic>> _sortedOrders = [];

  @override
  void initState() {
    super.initState();
    _applyNNA();
    _saveDeliveries();
    
  }

  Future<void> _saveDeliveries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_list', jsonEncode(_sortedOrders));

    print('Deliveries saved successfully!');
    print('Number of orders saved: ${_sortedOrders.length}');
    print('Saved data: ${jsonEncode(_sortedOrders)}');
  }

  // Apply Nearest Neighbor Algorithm (NNA) to sort orders
  void _applyNNA() {
    List<Map<String, dynamic>> unvisitedOrders =
        List.from(widget.selectedOrders);
    _sortedOrders.clear();

    // Start at the store
    LatLng currentLocation = LatLng(storeLat, storeLon);

    while (unvisitedOrders.isNotEmpty) {
      // Find the nearest customer from the current location
      Map<String, dynamic> nearestOrder =
          _findNearestOrder(currentLocation, unvisitedOrders);
      _sortedOrders.add(nearestOrder);

      // Update the current location to the nearest customer
      LatLng nextLocation = LatLng(
        double.parse(nearestOrder['customer']['lat'] ?? '0'),
        double.parse(nearestOrder['customer']['long'] ?? '0'),
      );

      // Print the distance between the current location and the next customer
      double distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        nextLocation.latitude,
        nextLocation.longitude,
      );
      print(
          'Distance from Store (${currentLocation.latitude}, ${currentLocation.longitude}) '
          'to (${nextLocation.latitude}, ${nextLocation.longitude}): ${distance.toStringAsFixed(2)} km');

      // Update the current location
      currentLocation = nextLocation;

      // Remove the nearest customer from the unvisited list
      unvisitedOrders.remove(nearestOrder);
    }

    // Add a marker for the store
    _markers.add(Marker(
      markerId: MarkerId('store'),
      position: LatLng(storeLat, storeLon),
      infoWindow: InfoWindow(title: 'Store'),
    ));

    // Add markers for customers and calculate the route
    List<LatLng> routePoints = [LatLng(storeLat, storeLon)];

    for (int i = 0; i < _sortedOrders.length; i++) {
      final order = _sortedOrders[i];
      double customerLat = double.parse(order['customer']['lat'] ?? '0');
      double customerLon = double.parse(order['customer']['long'] ?? '0');
      String address = order['customer']['address'] ?? 'No Address Available';
      String orderId = order['id'].toString();

      _markers.add(Marker(
        markerId: MarkerId('customer_$i'),
        position: LatLng(customerLat, customerLon),
        infoWindow: InfoWindow(
          title: 'Order ID: $orderId',
          snippet: 'Address: $address',
        ),
      ));

      routePoints.add(LatLng(customerLat, customerLon));
    }

    _getDirections(routePoints);
  }

  // Find the nearest order from the current location
// Find the nearest order from the current location
  Map<String, dynamic> _findNearestOrder(
      LatLng currentLocation, List<Map<String, dynamic>> orders) {
    Map<String, dynamic> nearestOrder = orders[0];
    double nearestDistance = double.infinity;

    print(
        '\nCurrent Location: (${currentLocation.latitude}, ${currentLocation.longitude})');

    for (var order in orders) {
      double customerLat = double.parse(order['customer']['lat'] ?? '0');
      double customerLon = double.parse(order['customer']['long'] ?? '0');
      double distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        customerLat,
        customerLon,
      );

      print(
          'Order ID: ${order['id']}, Distance: ${distance.toStringAsFixed(2)} km');

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestOrder = order;
      }
    }

    print(
        'Nearest Order Selected: ID ${nearestOrder['id']} with Distance: ${nearestDistance.toStringAsFixed(2)} km\n');

    return nearestOrder;
  }

  // Rest of the code remains the same...
  Future<void> _getDirections(List<LatLng> routePoints) async {
    List<LatLng> polylineCoordinates = [];

    for (int i = 0; i < routePoints.length - 1; i++) {
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${routePoints[i].latitude},${routePoints[i].longitude}&destination=${routePoints[i + 1].latitude},${routePoints[i + 1].longitude}&key=$googleMapsApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          var route = data['routes'][0]['legs'][0]['steps'];
          for (var step in route) {
            var polyline = step['polyline']['points'];
            polylineCoordinates.addAll(_decodePolyline(polyline));
          }
        }
      } else {
        throw Exception('Failed to load directions');
      }
    }

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: polylineCoordinates,
        color: kPrimaryColor,
        width: 4,
      ));
    });
  }

  // Decode polyline encoded string
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery List'),
      ),
      body: widget.selectedOrders.isEmpty
          ? Center(
              child:
                  Text("No current delivery", style: TextStyle(fontSize: 16)),
            )
          : Column(
              children: [
                Expanded(
                  child: SizedBox(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(storeLat, storeLon),
                        zoom: 18,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _markers,
                      polylines: _polylines,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _sortedOrders.length,
                    itemBuilder: (context, index) {
                      final order = _sortedOrders[index];
                      String orderId = order['id'].toString();
                      String address = order['customer']['address'] ??
                          'No Address Available';
                      return ListTile(
                        title: Text("Order ID: $orderId",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Address: $address\nDistance: ${calculateDistance(
                          storeLat,
                          storeLon,
                          double.parse(order['customer']['lat'] ?? '0'),
                          double.parse(order['customer']['long'] ?? '0'),
                        ).toStringAsFixed(2)} km'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveDeliveries();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InitScreen( initialIndex: 1,
                              
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Start Delivery',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}
