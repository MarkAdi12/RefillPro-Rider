import 'package:flutter/material.dart';
import 'package:rider_and_clerk_application/constants.dart';
import 'package:rider_and_clerk_application/screens/pick%20up/components/create_order.dart';
import 'package:rider_and_clerk_application/screens/pick%20up/components/refill_form.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    if (_selectedIndex == 0) {
      currentScreen = CreateOrder();
    } else if (_selectedIndex == 1) {
      currentScreen = RefillScreen();
    } else {
      currentScreen = Container();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedIndex = 0; 
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedIndex == 0
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                      
                    ),
                  ),
                ),
                child: Text(
                  'Create Order',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedIndex == 1
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Refill',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: currentScreen),
        ],
      ),
    );
  }
}
