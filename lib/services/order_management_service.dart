import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String ordersUrl = 'https://refillpro.store/api/v1/orders/';

  Future<List<dynamic>> fetchOrders(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(ordersUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to load orders. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

  Future<bool> updateOrder(
      String accessToken, int orderId, DateTime deliveryDateTime) async {
    final String updateOrderUrl =
        'https://refillpro.store/api/v1/orders/$orderId/';

    try {
      final response = await http.post(
        Uri.parse(updateOrderUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'status': 1,
          'action': 'update',
          'delivery_datetime': deliveryDateTime.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print("Order updated successfully");
        return true;
      } else {
        print("Failed to update order: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating order: $e");
      return false;
    }
  }

  Future retrievePayment(String accessToken, int orderId) async {
    final String paymentUrl =
        'https://refillpro.store/api/v1/rider/payments/$orderId/';

    print('Request URL: $paymentUrl'); 

    try {
      final response = await http.get(
        Uri.parse(paymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          print("Received list: $data");
          return data[0];
        } else if (data is Map) {
          print("Received map: $data");
          return data;
        } else {
          print("Unexpected response format: $data");
          return null;
        }
      } else {
        print("Failed to retrieve payment: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error retrieving payment: $e");
      return null;
    }
  }
}
