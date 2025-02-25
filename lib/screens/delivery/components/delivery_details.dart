import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../services/order_management_service.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/payment_service.dart';

class DraggableSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  final FlutterSecureStorage secureStorage;
  final Function(int orderId) onCompleteDelivery;
  final String paymentStatus;

  DraggableSheet({
    Key? key,
    required this.order,
    required this.secureStorage,
    required this.onCompleteDelivery,
    required this.paymentStatus,
  }) : super(key: key);

  @override
  _DraggableSheetState createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  Future<void> _updateOrderStatusInFirebase(String orderId, int status) async {
    await _database.child('orders/$orderId').set({
      'status': status,
    });
    print('Order $orderId status updated to $status');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.16,
      minChildSize: 0.16,
      maxChildSize: 0.45,
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
              ),
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
                      '${widget.order['customer']['first_name']} ${widget.order['customer']['last_name']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final phoneNumber = {
                              widget.order['customer']['phone_number']
                            };
                            final Uri telUri = Uri.parse("tel:$phoneNumber");
                            if (await canLaunchUrl(telUri)) {
                              await launchUrl(telUri);
                            } else {
                              print("Could not launch dialer");
                            }
                          },
                          child:
                              Icon(Icons.phone, size: 22, color: kPrimaryColor),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final String phoneNumber =
                                widget.order['customer']['phone_number'];
                            final Uri smsUri = Uri.parse("sms:$phoneNumber");

                            if (await canLaunchUrl(smsUri)) {
                              await launchUrl(smsUri);
                            } else {
                              print("Could not launch messaging app");
                            }
                          },
                          child: Icon(Icons.message_rounded,
                              size: 22, color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('${widget.order['customer']['address']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16)),
                Text('Delivery Instruction:',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  '${widget.order['remarks']?.isNotEmpty ?? false ? widget.order['remarks'] : "None"}',
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text('Order Summary',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children:
                      widget.order['order_details']?.map<Widget>((orderDetail) {
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
                    Text('₱${widget.order['order_details'][0]['total_price']}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('₱${widget.order['order_details'][0]['total_price']}'),
                  ],
                ),
                if (widget.paymentStatus.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.paymentStatus == 'Paid'
                            ? 'Paid Online'
                            : widget.paymentStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                final String? token = await widget.secureStorage
                                    .read(key: 'access_token');
                                if (token == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Access token not found. Please log in again.'),
                                    ),
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }

                                int orderId = widget.order['id'];

                                // Convert amount safely
                                double? orderAmount = double.tryParse(widget
                                        .order['order_details']?[0]
                                            ?['total_price']
                                        ?.toString() ??
                                    "0.0");

                                if (orderAmount == null || orderAmount <= 0) {
                                  print(
                                      "Error: Invalid order amount for Order ID: $orderId");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid order amount.')),
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }

                                DateTime deliveryDateTime = DateTime.now();
                                int status = 4;

                                final paymentData = await PaymentService()
                                    .retrievePayment(token, orderId);

                                if (paymentData == null) {
                                  // If no payment exists, create a cash payment.
                                  await PaymentService().createPayment(
                                    token,
                                    orderId,
                                    0, // Cash payment method
                                    "", // No reference code for cash
                                    orderAmount.toStringAsFixed(
                                        2), // Convert double to formatted string
                                    "Auto-generated cash payment",
                                    // Payment status (1 = completed)
                                  );
                                  print(
                                      "Auto-created cash payment for Order ID: $orderId, Amount: $orderAmount");
                                } else {
                                  print(
                                      "Payment already exists for Order ID: $orderId, skipping creation.");
                                }
                                print(
                                    "Updating order status for Order ID: $orderId...");
                                bool isUpdated = await OrderService()
                                    .updateOrder(token, orderId,
                                        deliveryDateTime, status);

                                if (isUpdated) {
                                  print(
                                      "Order ID: $orderId successfully updated to status $status.");
                                  await _updateOrderStatusInFirebase(
                                      orderId.toString(), 4);
                                  widget.onCompleteDelivery(orderId);
                                } else {
                                  print(
                                      "Failed to update order for Order ID: $orderId");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Failed to update order. Please try again.')),
                                  );
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Complete Delivery'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final String? token = await widget.secureStorage
                                    .read(key: 'access_token');
                                if (token == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Access token not found. Please log in again.'),
                                    ),
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }

                                DateTime deliveryDateTime = DateTime.now();
                                int status = 6;
                                int orderId = widget.order['id'];
                                bool isUpdated = await OrderService()
                                    .updateOrder(token, orderId,
                                        deliveryDateTime, status);

                                if (isUpdated) {
                                  print(
                                      "Order ID: $orderId successfully updated to status $status.");
                                  await _updateOrderStatusInFirebase(
                                      orderId.toString(), 6);
                                  widget.onCompleteDelivery(orderId);
                                } else {
                                  print(
                                      "Failed to update order for Order ID: $orderId");
                                  await _updateOrderStatusInFirebase(
                                      orderId.toString(), 6);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to update order. Please try again.'),
                                    ),
                                  );
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Failed Delivery'),
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
