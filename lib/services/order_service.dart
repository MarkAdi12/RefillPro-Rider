import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static Future<List<Map<String, dynamic>>> loadSavedOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('delivery_list');

    if (savedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(savedData));
    } else {
      return [];
    }
  }

  static Future<void> clearSelectedDelivery(int orderId, List<Map<String, dynamic>> sortedOrders) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sortedOrders.removeWhere((order) => order['id'] == orderId);
    await prefs.setString('delivery_list', jsonEncode(sortedOrders));
  }
}
