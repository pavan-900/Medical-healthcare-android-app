import 'package:flutter/material.dart';
import '../introduction/third_page.dart'; // Import ThirdPage
import '../pages/home_page.dart';
class AirdropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // Skip to ThirdPage
              );
            },
            child: Text(
              "Skip",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3, // Larger image area
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(
                'assets/images/airdrop2.jpg', // Replace with your image
                height: MediaQuery.of(context).size.height * 0.6, // Set height to 60% of screen
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Get airdropped tokens in calamities", // Placeholder title
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "In times of calamity, we will automatically airdrop our tokens into your wallets.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Progress Indicators
                Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: Colors.grey[300]),
                    SizedBox(width: 5),
                    CircleAvatar(radius: 5, backgroundColor: Colors.black), // Current page
                    SizedBox(width: 5),
                    CircleAvatar(radius: 5, backgroundColor: Colors.grey[300]),
                    SizedBox(width: 5),
                    CircleAvatar(radius: 5, backgroundColor: Colors.grey[300]),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 1000), // Smooth slow animation
                        pageBuilder: (_, __, ___) => ThirdPage(), // Navigate to ThirdPage
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(-1, 0), // Start from right
                              end: Offset(0, 0), // End at the center
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.black,
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
