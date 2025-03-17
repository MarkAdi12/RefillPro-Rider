import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'components/settings_menu.dart';
import '../../../services/auth_service.dart';

class MenuScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  MenuScreen({super.key});

  void _logout(BuildContext context) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    // Remove stored access token and refresh token
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');

    // Clear delivery_list and pending_list from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'delivery_list', jsonEncode([])); // Clear delivery_list
    await prefs.setString('pending_list', jsonEncode([])); // Clear pending_list

    // Redirect to login screen
    _authService.cancelLogoutTimer();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Account',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ProfileMenu(
              text: "Log Out",
              icon: Icons.logout_rounded,
              press: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
