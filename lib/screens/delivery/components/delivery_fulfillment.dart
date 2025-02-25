// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_and_clerk_application/screens/init_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../constants.dart';
import '../../../services/google_api_service.dart';
import '../../../services/location_service.dart';
import '../../../services/payment_service.dart';
import '../../../utils/polyline_util.dart';
import 'delivery_details.dart';
import 'package:firebase_database/firebase_database.dart';

class DeliveryFulfillment extends StatefulWidget {
  final Map<String, dynamic> order;

  const DeliveryFulfillment({super.key, required this.order});

  @override
  _DeliveryFulfillmentState createState() => _DeliveryFulfillmentState();
}

class _DeliveryFulfillmentState extends State<DeliveryFulfillment> {
  late GoogleMapController _mapController;
  bool _cameraMoved = false;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  Set<Circle> _circles = {};
  late double customerLatitude;
  late double customerLongitude;
  String _distance = '';
  String _duration = '';
  LatLng? currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _locationTimer;
  bool _routeFetched = false;
  bool _isLoadingPayment = false;
  String _paymentStatusText = '';
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    customerLatitude =
        double.tryParse(widget.order['customer']['lat'] ?? '0') ?? 0.0;
    customerLongitude =
        double.tryParse(widget.order['customer']['long'] ?? '0') ?? 0.0;
    _getCurrentLocation();
    _locationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentLocation();
    });
    _fetchPayment();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
    _fetchPayment();
  }

  void _fetchPayment() async {
    setState(() {
      _isLoadingPayment = true;
    });

    String? token = await _secureStorage.read(key: 'access_token');
    if (token == null) {
      print("Error: Access token not found.");
      return;
    }

    try {
      final paymentData =
          await PaymentService().retrievePayment(token, widget.order['id']);
      print('Received payment data: $paymentData');
      if (!mounted) return;
      setState(() {
        _isLoadingPayment = false;
      });

      if (paymentData != null) {
        if (paymentData['status'] == 1) {
          setState(() {
            _paymentStatusText = 'Paid Online';
          });
          print('Paid');
        } else if (paymentData['status'] == 0) {
          setState(() {
            _paymentStatusText = 'Online Payment Pending';
          });
          print('Pending');
        }
      }
    } catch (e) {
      print("Error retrieving payment: $e");
      if (mounted) {
        setState(() {
          _isLoadingPayment = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error retrieving payment data.")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    LatLng? location = await LocationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        currentLocation = location;
        _addMarkers();

        if (!_cameraMoved && _mapController != null) {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(location, 16),
          );
          _cameraMoved = true;
        }

        if (currentLocation != null &&
            customerLatitude != 0.0 &&
            customerLongitude != 0.0 &&
            !_routeFetched) {
          _getRoute(
              currentLocation!, LatLng(customerLatitude, customerLongitude));
          _routeFetched = true;
        }
      });
      _updateLocationInDatabase(location);
    }
  }

  Future<void> _updateLocationInDatabase(LatLng location) async {
    DatabaseReference locationRef = _database.ref('location');
    try {
      await locationRef.update({
        'lat': location.latitude,
        'long': location.longitude,
      });
      print('Location updated in Firebase');
    } catch (e) {
      print('Error updating location in Firebase: $e');
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final String apiKey =
        'dsds'; // REPLACE WITH REAL API KEY AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk
    final data = await ApiService.getRoute(start, end, apiKey);
    if (data['routes'].isNotEmpty) {
      final route = data['routes'][0];
      final polylinePoints = route['overview_polyline']['points'];
      _clearPolyline();
      _addPolyline(polylinePoints);
      final distance = route['legs'][0]['distance']['text'];
      final duration = route['legs'][0]['duration']['text'];
      setState(() {
        _distance = distance;
        _duration = duration;
      });
    } else {
      print('No routes found in the response.');
    }
  }

  void _addPolyline(String polylinePoints) {
    final polylineCoordinates = PolylineUtils.decodePolyline(polylinePoints);
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 6,
          points: polylineCoordinates,
        ),
      );
    });
  }

  void _addMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId("customer_location"),
        position: LatLng(customerLatitude, customerLongitude),
        infoWindow: InfoWindow(
          title: "Customer's Location",
          snippet: widget.order['customer']['address'],
        ),
      ),
    );

    if (currentLocation != null) {
      _markers
          .removeWhere((marker) => marker.markerId.value == "current_location");

      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: currentLocation!,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  Future<void> clearSelectedDelivery(int orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> sortedOrders = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('delivery_list') ?? '[]'));
    sortedOrders.removeWhere((order) => order['id'] == orderId);
    await prefs.setString('delivery_list', jsonEncode(sortedOrders));
    if (mounted) {
      setState(() {});
    }
  }

  void _clearPolyline() {
    setState(() {
      _polylines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delivery")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentLocation != null &&
                                customerLatitude != 0.0 &&
                                customerLongitude != 0.0
                            ? LatLng(
                                (currentLocation!.latitude + customerLatitude) /
                                    2,
                                (currentLocation!.longitude +
                                        customerLongitude) /
                                    2,
                              )
                            : LatLng(customerLatitude, customerLongitude),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _markers,
                      polylines: _polylines,
                    ),
                    // Camera Controller - Rider Loc
                    Positioned(
                      bottom: 550,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          if (currentLocation != null) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(currentLocation!, 16),
                            );
                          }
                        },
                        child: Icon(Icons.my_location, color: kPrimaryColor),
                      ),
                    ),
                    // Camera Controller - Customer Loc
                    Positioned(
                      bottom: 480,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          if (customerLatitude != 0.0 &&
                              customerLongitude != 0.0) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(customerLatitude, customerLongitude),
                                16,
                              ),
                            );
                          }
                        },
                        child: Icon(Icons.location_history_rounded,
                            color: kPrimaryColor),
                      ),
                    ),
                  ],
                )),
          ),
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 6, spreadRadius: 1)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Order ID: ${widget.order['id']}',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 25, color: kPrimaryColor),
                          SizedBox(width: 4),
                          Text(
                            _distance,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 25, color: kPrimaryColor),
                          SizedBox(width: 4),
                          Text(
                            _duration,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DraggableSheet(
            order: widget.order,
            secureStorage: _secureStorage,
            onCompleteDelivery: (orderId) async {
              await clearSelectedDelivery(orderId);
              if (mounted) {
                setState(() {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InitScreen(
                                initialIndex: 1,
                              )));
                });
              }
            },
            paymentStatus: _paymentStatusText,
          )
        ],
      ),
    );
  }
}
