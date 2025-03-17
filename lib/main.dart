// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/screens/init_screen.dart';
import 'package:rider_and_clerk_application/screens/sign_in/sign_in_screen.dart';
import 'package:rider_and_clerk_application/screens/splash.dart';
import 'package:rider_and_clerk_application/services/notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  runApp(const MainApp());
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key}); 
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      home: SignInScreen()
      );
  }
}
