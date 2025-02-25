import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
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

  Future createPayment(
    String accessToken,
    int orderId,
    int payment_method,
    String ref_code,
    String amount,
    String remarks,

  ) async {
    final String createpaymentUrl =
        'https://refillpro.store/api/v1/rider/payments/';

    print('Request URL: $createpaymentUrl');

    try {
      final response = await http.post(
        Uri.parse(createpaymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "order_id": orderId,
          "payment_method": 0,
          "ref_code": ref_code,
          "amount": amount,
          "remarks": remarks,
          "status": 1,
        }),
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
        print("Failed to create payment: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error creating payment: $e");
      return null;
    }
  }
}
