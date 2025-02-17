import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../constants.dart';
import '../../../services/order_management_service.dart';

class DraggableSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final FlutterSecureStorage secureStorage;
  final Function(int orderId) onCompleteDelivery;

  const DraggableSheet(
      {super.key, required this.order, required this.secureStorage, required this.onCompleteDelivery});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.16,
      minChildSize: 0.16,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
              )
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text('Customer Details',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(
                      '${order['customer']['first_name']} ${order['customer']['last_name']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, size: 22, color: kPrimaryColor),
                        SizedBox(width: 8),
                        Icon(Icons.message_rounded,
                            size: 22, color: kPrimaryColor),
                      ],
                    ),
                  ],
                ),
                Text('${order['customer']['address']}',
                    style: TextStyle(fontSize: 16)),
                Text('Delivery Instruction:',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  '${order['remarks']?.isNotEmpty ?? false ? order['remarks'] : "None"}',
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text('Order Summary',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children: order['order_details']?.map<Widget>((orderDetail) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${double.parse(orderDetail['quantity']).toInt()} x ${orderDetail['product']['name']}'),
                            Text('${orderDetail['total_price']}'),
                          ],
                        );
                      }).toList() ??
                      [Text("No items in order")],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('₱${order['order_details'][0]['total_price']}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('₱${order['order_details'][0]['total_price']}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () async {
                          String? token = await secureStorage.read(
                              key: 'access_token');
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Access token not found. Please log in again.')),
                            );
                            return;
                          }

                          int orderId = order['id'];
                          bool isUpdated = await OrderService()
                              .updateOrder(token, orderId);
                          if (isUpdated) {
                            onCompleteDelivery(orderId); 
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to update order. Please try again.')),
                            );
                          }
                        },
                        child: Text('Complete Delivery'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
