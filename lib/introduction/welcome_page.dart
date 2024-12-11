import 'package:flutter/material.dart';
import '../introduction/register_page.dart'; // Updated path for RegisterPage

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // White background
          Container(
            color: Colors.white, // Set the background color to white
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Image.asset(
                    'assets/images/first2.jpg', // Replace with your image
                    height: MediaQuery.of(context).size.height * 0.5, // Larger image height (50% of screen height)
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 30),
                // Welcome Text
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Changed text color to black for contrast
                  ),
                ),
                SizedBox(height: 15),
                // Subtitle Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    "Move insurance to the realm of crypto!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800], // Subtle gray for subtitle
                    ),
                  ),
                ),
                SizedBox(height: 50),
                // Button to proceed
                ElevatedButton(
                  onPressed: () {
                    // Navigate to RegisterPage with animation
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 500),
                        pageBuilder: (_, __, ___) => RegisterPage(),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 1), // Start from the bottom
                              end: Offset(0, 0),
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.black, // Dark button for contrast
                  ),
                  child: Text(
                    "Let's begin",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
