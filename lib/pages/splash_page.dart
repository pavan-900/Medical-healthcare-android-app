import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';

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

    // Navigate to HomePage after 7 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
            color: Colors.white, // Background color set to white
          ),
          // Animated logo
          AnimatedPositioned(
            duration: Duration(seconds: 2), // Animation duration
            curve: Curves.easeOut, // Smooth curve
            bottom: _logoVisible ? MediaQuery.of(context).size.height / 2 - 250 : -500, // Adjusted for larger image
            left: MediaQuery.of(context).size.width / 2 - 250, // Adjusted for larger image
            child: Container(
              width: 500, // Significantly increased width
              height: 500, // Significantly increased height
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
