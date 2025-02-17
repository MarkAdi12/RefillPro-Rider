// nna_service.dart
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NNA {
  static List<Map<String, dynamic>> applyNNA(
    List<Map<String, dynamic>> selectedOrders,
    double storeLat,
    double storeLon) {
    List<Map<String, dynamic>> unvisitedOrders = List.from(selectedOrders);
    List<Map<String, dynamic>> sortedOrders = [];
    LatLng currentLocation = LatLng(storeLat, storeLon);

    while (unvisitedOrders.isNotEmpty) {
      Map<String, dynamic> nearestOrder =
          _findNearestOrder(currentLocation, unvisitedOrders);
      sortedOrders.add(nearestOrder);
      currentLocation = LatLng(
        double.parse(nearestOrder['customer']['lat'] ?? '0'),
        double.parse(nearestOrder['customer']['long'] ?? '0'),
      );
      unvisitedOrders.remove(nearestOrder);
    }

    return sortedOrders;
  }

  static Map<String, dynamic> _findNearestOrder(
      LatLng currentLocation, List<Map<String, dynamic>> orders) {
    Map<String, dynamic> nearestOrder = orders[0];
    double nearestDistance = double.infinity;

    for (var order in orders) {
      double customerLat = double.parse(order['customer']['lat'] ?? '0');
      double customerLon = double.parse(order['customer']['long'] ?? '0');
      double distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        customerLat,
        customerLon,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestOrder = order;
      }
    }

    return nearestOrder;
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
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

  static double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}
