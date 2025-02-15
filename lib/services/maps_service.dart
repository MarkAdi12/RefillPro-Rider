import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  static Set<Marker> generateMarkers(List<Map<String, dynamic>> sortedOrders) {
    Set<Marker> markers = {};


    final double storeLat = 14.7168122;
    final double storeLon = 120.9553401;
    markers.add(Marker(
      markerId: MarkerId('store'),
      position: LatLng(storeLat, storeLon),
      infoWindow: InfoWindow(title: 'Store'),
    ));

    for (int i = 0; i < sortedOrders.length; i++) {
      final order = sortedOrders[i];
      double customerLat = double.parse(order['customer']['lat'] ?? '0');
      double customerLon = double.parse(order['customer']['long'] ?? '0');
      String address = order['customer']['address'] ?? 'No Address Available';
      String orderId = order['id'].toString();

      markers.add(Marker(
        markerId: MarkerId('customer_$i'),
        position: LatLng(customerLat, customerLon),
        infoWindow: InfoWindow(title: 'Order ID: $orderId', snippet: 'Address: $address'),
      ));
    }

    return markers;
  }
}
