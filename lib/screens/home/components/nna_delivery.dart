import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/init_screen.dart';
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
  final String googleMapsApiKey = 'SECRET'; // AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk
  final double storeLat = 14.7168122;
  final double storeLon = 120.9553401;
  List<Map<String, dynamic>> _sortedOrders = [];

  double _totalDistanceBeforeSorting = 0.0;
  double _totalDistanceAfterSorting = 0.0;
  double _totalSavedDistance = 0.0;
  double _improvementPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _applyNNA();
    _saveDeliveries();
    _calculateTotalDistanceBeforeSorting();
    _calculateTotalDistanceAfterSorting();
  }

  void _calculateTotalDistanceBeforeSorting() {
    _totalDistanceBeforeSorting = 0.0;
    LatLng currentLocation = LatLng(storeLat, storeLon);
    for (var order in widget.selectedOrders) {
      double customerLat = double.parse(order['customer']['lat'] ?? '0');
      double customerLon = double.parse(order['customer']['long'] ?? '0');
      double distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        customerLat,
        customerLon,
      );
      print(
          'Before Sorting -> Order ID: ${order['id']}, Distance: ${distance.toStringAsFixed(2)} km');
      _totalDistanceBeforeSorting += distance;
      currentLocation = LatLng(customerLat, customerLon);
    }
    print(
        'Total Distance Before Sorting: ${_totalDistanceBeforeSorting.toStringAsFixed(2)} km');
  }

  void _calculateTotalDistanceAfterSorting() {
    _totalDistanceAfterSorting = 0.0;
    LatLng currentLocation = LatLng(storeLat, storeLon);

    for (var order in _sortedOrders) {
      double? customerLat = double.tryParse(order['customer']['lat'] ?? '');
      double? customerLon = double.tryParse(order['customer']['long'] ?? '');

      if (customerLat != null && customerLon != null) {
        double distance = calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          customerLat,
          customerLon,
        );
        _totalDistanceAfterSorting += distance;
        currentLocation = LatLng(customerLat, customerLon);
      }
    }

    _totalSavedDistance =
        _totalDistanceBeforeSorting - _totalDistanceAfterSorting;
    _improvementPercentage = (_totalDistanceBeforeSorting > 0)
        ? (_totalSavedDistance / _totalDistanceBeforeSorting) * 100
        : 0.0;
  }

  Future<void> _saveDeliveries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_list', jsonEncode(_sortedOrders));
    print('Deliveries saved successfully!');
    print('Number of orders saved: ${_sortedOrders.length}');
    print('Saved data: ${jsonEncode(_sortedOrders)}');
  }

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
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet), // Change color
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

  Future<void> _getDirections(List<LatLng> routePoints) async {
    if (routePoints.length < 2) return;
    print('API request has been called! Requesting route from '
        '${routePoints.first.latitude},${routePoints.first.longitude} '
        'to ${routePoints.last.latitude},${routePoints.last.longitude}');

    List<String> waypoints = routePoints
        .sublist(1, routePoints.length - 1)
        .map((point) => '${point.latitude},${point.longitude}')
        .toList();

    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${routePoints.first.latitude},${routePoints.first.longitude}'
        '&destination=${routePoints.last.latitude},${routePoints.last.longitude}'
        '&waypoints=${waypoints.join('|')}'
        '&key=$googleMapsApiKey';
    print("API request has been called!");
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> polylineCoordinates = [];
        var points = data['routes'][0]['overview_polyline']['points'];
        polylineCoordinates.addAll(_decodePolyline(points));
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: polylineCoordinates,
            color: kPrimaryColor,
            width: 4,
          ));
        });
      }
    } else {
      throw Exception('Failed to load directions');
    }
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
        title: Text('Selected Orders'),
      ),
      body: widget.selectedOrders.isEmpty
          ? Center(
              child:
                  Text("No current delivery", style: TextStyle(fontSize: 16)),
            )
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Before sorting: ${_totalDistanceBeforeSorting.toStringAsFixed(2)} km\n'
                  'Optimized list: ${_totalDistanceAfterSorting.toStringAsFixed(2)} km\n'
                  'Total saved distance: ${_totalSavedDistance.toStringAsFixed(2)} km\n'
                  'Efficiency improvement: ${_improvementPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(storeLat, storeLon),
                      zoom: 14,
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
                    String address =
                        order['customer']['address'] ?? 'No Address Available';
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
                          builder: (context) => InitScreen(initialIndex: 1),
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
                    child:
                        Text('Start Delivery', style: TextStyle(fontSize: 16)),
                  ),
                ),
              )
            ]),
    );
  }

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Earth's radius in kilometers
    const double earthRadius = 6371;

    // Convert latitude and longitude differences from degrees to radians
    double dLat = _degToRad(lat2 - lat1); // Difference in latitude
    double dLon = _degToRad(lon2 - lon1); // Difference in longitude

    // Haversine formula to calculate the distance between two points on a sphere
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(_degToRad(lat1)) *
               cos(_degToRad(lat2)) *
               sin(dLon / 2) *
               sin(dLon / 2);

    // Calculate the angular distance in radians
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Return the distance in kilometers by multiplying the angular distance by Earth's radius
    return earthRadius * c;
}

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}