import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON parsing
import 'dart:async'; // For Timer
import '../../../services/location_service.dart';

class GoogleMapScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const GoogleMapScreen({super.key, required this.order});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  late double customerLatitude;
  late double customerLongitude;
  String _distance = '';
  String _duration = '';
  LatLng? currentLocation; // Nullable LatLng to store the current location
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _locationTimer; // Timer for updating location

  @override
  void initState() {
    super.initState();
    // Initialize customer location from order data
    customerLatitude =
        double.tryParse(widget.order['customer']['lat'] ?? '0') ?? 0.0;
    customerLongitude =
        double.tryParse(widget.order['customer']['long'] ?? '0') ?? 0.0;

    // Get the current location using the LocationService
    _getCurrentLocation();

    // Start a timer to update the current location periodically
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  // Get current location of the rider
  Future<void> _getCurrentLocation() async {
    LatLng? location = await LocationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        currentLocation = location;
        _addMarkers();
        if (currentLocation != null &&
            customerLatitude != 0.0 &&
            customerLongitude != 0.0) {
          _getRoute(
              currentLocation!, LatLng(customerLatitude, customerLongitude));
        }
      });
    }
  }

  // Add markers for customer and rider locations
  void _addMarkers() {
    _markers.clear(); // Clear existing markers
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
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: currentLocation!,
          infoWindow: InfoWindow(
            title: "Current Location",
            snippet: "This is your current location",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  // Fetch the route from Directions API and add polyline
  Future<void> _getRoute(LatLng start, LatLng end) async {
    final String apiKey =
        'AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk'; // Replace with your API key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey',
    );

    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final polylinePoints = route['overview_polyline']['points'];
        print('Polyline points: $polylinePoints');
        _clearPolyline(); // Clear the old polyline before adding new one
        _addPolyline(polylinePoints);

        // Extract distance and duration
        final distance = route['legs'][0]['distance']['text'];
        final duration = route['legs'][0]['duration ']['text'];

        // Update the UI with the distance and duration
        setState(() {
          _distance = distance; // Store the distance
          _duration = duration; // Store the duration
        });
      } else {
        print('No routes found in the response.');
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // Clear the existing polyline
  void _clearPolyline() {
    setState(() {
      _polylines.clear();
    });
  }

  // Decode polyline and add to the map
  void _addPolyline(String polylinePoints) {
    final polylineCoordinates = _decodePolyline(polylinePoints);
    print('Decoded polyline coordinates: $polylineCoordinates');

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 6,
          points: polylineCoordinates,
        ),
      );
      print('Polylines: $_polylines');
    });
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < len);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < len);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delivery")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Google Map
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation != null &&
                          customerLatitude != 0.0 &&
                          customerLongitude != 0.0
                      ? LatLng(
                          (currentLocation!.latitude + customerLatitude) /
                              2, // Midpoint latitude
                          (currentLocation!.longitude + customerLongitude) /
                              2, // Midpoint longitude
                        )
                      : LatLng(customerLatitude,
                          customerLongitude), // Default if current location is unavailable
                  zoom: 16,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: _markers,
                polylines: _polylines,
                onCameraMove: (CameraPosition position) {
                  // Update the current camera position when the user drags the map
                  setState(() {
                    currentLocation = position.target; // Update the current location with the new camera position
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Customer info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID:', style: TextStyle(fontSize: 16)),
                      Text('${widget.order['id']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address:', style: TextStyle(fontSize: 14)),
                      Text('${widget.order['customer']['address']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone Number:', style: TextStyle(fontSize: 14)),
                      Text('${widget.order['customer']['phone_number']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name:', style: TextStyle(fontSize: 14)),
                      Text(
                          '${widget.order['customer']['first_name']} ${widget.order['customer']['last_name']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text('Delivery Instruction:', style: TextStyle(fontSize: 14)),
                  Text(
                      '${widget.order['remarks']?.isNotEmpty ?? false ? widget.order['remarks'] : "None"}',
                      style: TextStyle(fontSize: 16)),
                  Text('Distance: $_distance', style: TextStyle(fontSize: 16)),
                  Text('Duration: $_duration', style: TextStyle(fontSize: 16)),
                  Divider(),

                  // Order Summary
                  Text('Order Summary', style: TextStyle(fontSize: 16)),
                  Column(
                    children: widget.order['order_details']
                            ?.map<Widget>((orderDetail) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${orderDetail['quantity']} x ${orderDetail['product']['name']}'),
                              Text('${orderDetail['total_price']}'),
                            ],
                          );
                        }).toList() ??
                        [
                          Text("No items in order")
                        ], // Fallback if no details are available
                  ),

                  // Cash to Collect and Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cash to Collect:'),
                      Text('PHP '),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price: '),
                      Text('PHP ${widget.order['total_price']}'),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Buttons for completing or failing the delivery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            // Update the order status to "completed"
                            setState(() {
                              widget.order['status'] = 'completed';
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Delivery Completed"),
                              ));
                            });
                          },
                          child: Text('Complete Delivery'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () {
                            // Update the order status to "failed"
                            setState(() {
                              widget.order['status'] = 'failed';
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Delivery Failed"),
                              ));
                            });
                          },
                          child: Text('Fail Delivery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}