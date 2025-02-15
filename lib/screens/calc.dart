import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NNAcalculator extends StatefulWidget {
  @override
  _NNAcalculatorState createState() => _NNAcalculatorState();
}

class _NNAcalculatorState extends State<NNAcalculator> {
  final List<Map<String, double>> orders = [];
  List<Map<String, double>> sortedOrders = [];

  final double storeLat = 14.7168122;
  final double storeLon = 120.9553401;

  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  void _addOrder() {
    double lat = double.tryParse(_latController.text) ?? 0;
    double lon = double.tryParse(_lonController.text) ?? 0;

    if (lat != 0 && lon != 0) {
      setState(() {
        orders.add({'lat': lat, 'lon': lon});
        _latController.clear();
        _lonController.clear();
      });
    }
  }

  // Apply Nearest Neighbor Algorithm (NNA) to sort orders
  void _applyNNA() {
    List<Map<String, double>> unvisitedOrders = List.from(orders);
    sortedOrders.clear();

    // Start at the store
    LatLng currentLocation = LatLng(storeLat, storeLon);

    while (unvisitedOrders.isNotEmpty) {
      // Find the nearest customer from the current location
      Map<String, double> nearestOrder = _findNearestOrder(currentLocation, unvisitedOrders);
      sortedOrders.add(nearestOrder);

      // Update the current location to the nearest customer
      currentLocation = LatLng(nearestOrder['lat']!, nearestOrder['lon']!);

      // Remove the nearest customer from the unvisited list
      unvisitedOrders.remove(nearestOrder);
    }

    setState(() {});
  }

  // Find the nearest order from the current location
  Map<String, double> _findNearestOrder(LatLng currentLocation, List<Map<String, double>> orders) {
    Map<String, double> nearestOrder = orders[0];
    double nearestDistance = double.infinity;

    for (var order in orders) {
      double distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        order['lat']!,
        order['lon']!,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestOrder = order;
      }
    }

    return nearestOrder;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NNA Calculator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text fields for entering latitude and longitude
            TextField(
              controller: _latController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Enter Latitude',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lonController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Enter Longitude',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrder,
              child: Text("Add Order"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyNNA,
              child: Text("Calculate Route"),
            ),
            SizedBox(height: 20),
            // Display the sorted orders
            Expanded(
              child: ListView.builder(
                itemCount: sortedOrders.length,
                itemBuilder: (context, index) {
                  final order = sortedOrders[index];
                  double distance = calculateDistance(
                    storeLat,
                    storeLon,
                    order['lat']!,
                    order['lon']!,
                  );
                  return ListTile(
                    title: Text("Order ${index + 1}"),
                    subtitle: Text(
                      'Lat: ${order['lat']}, Lon: ${order['lon']}, Distance: ${distance.toStringAsFixed(2)} km',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
