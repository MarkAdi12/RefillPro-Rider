import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this package to your pubspec.yaml
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rider_and_clerk_application/screens/sign_in/sign_in_screen.dart'; // Add this package to your pubspec.yaml

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _secureStorage = FlutterSecureStorage(); // Initialize secure storage
  Timer? _logoutTimer; // Timer for auto-logout

  final String loginUrl = 'https://refillpro.store/api/v1/rider/login/';
  final String userUrl = 'https://refillpro.store/api/v1/user/';
  final String logoutUrl =
      'https://refillpro.store/api/v1/logout/'; // Logout endpoint

  // Logout function
  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Logout response: ${response.body}');

      if (response.statusCode == 200) {
        print('Logout successful');
        return true;
      } else {
        print('Logout failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during API logout: $e');
      return false;
    }
  }

  // Start the logout timer based on the token's expiration time
  void startLogoutTimer(String accessToken, BuildContext context) {
    // Decode the token to get the expiration time
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    int expiry = decodedToken['exp']; // Expiration time in seconds
    var currentTime =
        DateTime.now().millisecondsSinceEpoch / 1000; // Current time in seconds

    // Calculate the remaining time until the token expires
    int remainingTime = (expiry - currentTime).round();

    // Print the remaining time and logout time
    print('Token will expire in: $remainingTime seconds');
    print(
        'Logout will occur at: ${DateTime.fromMillisecondsSinceEpoch(expiry * 1000)}');

    // Set a timer to log the user out when the token expires
    _logoutTimer = Timer(Duration(seconds: remainingTime), () async {
      await _logout(accessToken, context);
    });
  }

  // Cancel the logout timer
  void cancelLogoutTimer() {
    _logoutTimer?.cancel();
    print('Logout timer canceled');
  }

  // Helper function to handle logout
  Future<void> _logout(String token, BuildContext context) async {
    try {
      // Call the API logout first
      bool apiLogoutSuccess = await logout(token);
      if (!apiLogoutSuccess) {
        throw Exception('API logout failed');
      }

      // Clear local data only if API logout is successful
      await _secureStorage.delete(key: 'access_token'); // Clear the token
      await _secureStorage.delete(key: 'user_data'); // Clear user data

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      print('Error during logout: $e');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  // Edit User Details
  Future<Map<String, dynamic>?> editUser(
      String accessToken, Map<String, dynamic> updatedData) async {
    final response = await http.post(
      Uri.parse(userUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to update user data: ${response.body}');
      return null;
    }
  }

  // Login Function
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  // Sign in with custom token
  Future<User?> signInWithCustomToken(String token) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCustomToken(token);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with custom token: $e');
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUser(String accessToken) async {
    final response = await http.get(
      Uri.parse(userUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Response Body: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch user data: ${response.body}');
      return null;
    }
  }
}
