import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final String loginUrl = 'https://refillpro.store/api/v1/rider/login/';
  final String userUrl = 'https://refillpro.store/api/v1/user/';


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

  Future<User?> signInWithCustomToken(String token) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithCustomToken(token);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with custom token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser (String accessToken) async {
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