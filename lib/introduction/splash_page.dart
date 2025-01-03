import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/sign-in_page.dart'; // Path to Sign-In Page

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _logoVisible = false; // To control the animation state

  @override
  void initState() {
    super.initState();

    // Trigger the animation after a short delay
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _logoVisible = true;
      });
    });

    // Navigate to SignInPage after 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: Colors.white,
          ),
          // Animated logo
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            curve: Curves.easeOut,
            bottom: _logoVisible
                ? MediaQuery.of(context).size.height / 2 - 250
                : -500,
            left: MediaQuery.of(context).size.width / 2 - 250,
            child: Container(
              width: 500,
              height: 500,
              child: Image.asset(
                'assets/images/splashlogo.png', // Path to your logo
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
