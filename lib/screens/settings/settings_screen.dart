import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rider_and_clerk_application/screens/calc.dart';

import '/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';

import 'components/settings_menu.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _logout(BuildContext context) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    await secureStorage.delete(key: 'access_token');  // Remove stored access token
    await secureStorage.delete(key: 'refresh_token'); // Remove refresh token

    // Redirect to login screen
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
              text: "Profile",
              icon: Icons.person_2_rounded,
              press: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NNAcalculator()))
              },
            ),
            ProfileMenu(
              text: "Change Password",
              icon: Icons.notifications,
              press: () {},
            ),
            ProfileMenu(
              text: "Settings",
              icon: Icons.settings,
              press: () {},
            ),
            ProfileMenu(
              text: "Help Center",
              icon: Icons.help,
              press: () {},
            ),
            ProfileMenu(
              text: "Log Out",
              icon: Icons.logout_rounded,
              press: () {
                _logout(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
