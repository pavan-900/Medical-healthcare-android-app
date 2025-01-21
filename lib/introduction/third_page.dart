import 'package:flutter/material.dart';
import '../introduction/SignupPromptPage.dart'; // Update path for SignupPromptPage

class ThirdPage extends StatefulWidget {
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _textController;

  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _textSlideAnimation;

  late Animation<double> _imageFadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _imageController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Image animations
    _imageSlideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Start from bottom
      end: Offset.zero, // End at its original position
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOut,
    ));

    _imageFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeIn,
    ));

    // Text animations
    _textSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5), // Start slightly below
      end: Offset.zero, // End at its original position
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Start animations sequentially
    _imageController.forward().then((_) => _textController.forward());
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupPromptPage()),
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
          // Animated Image Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AnimatedBuilder(
                animation: _imageController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _imageSlideAnimation,
                    child: FadeTransition(
                      opacity: _imageFadeAnimation,
                      child: Image.asset(
                        'assets/images/third.jpg', // Replace with your image
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Animated Text Section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Text(
                            "Gene Search",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Text(
                            "Find detailed information about specific genes linked to a condition.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Navigation Buttons
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
                    CircleAvatar(radius: 5, backgroundColor: Colors.grey[300]),
                    SizedBox(width: 5),
                    CircleAvatar(radius: 5, backgroundColor: Colors.black), // Current page
                    SizedBox(width: 5),
                    CircleAvatar(radius: 5, backgroundColor: Colors.grey[300]),
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 700), // Smooth animation
                          pageBuilder: (_, __, ___) => SignupPromptPage(), // Navigate to ThirdPage
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(-1, 0), // Start from the right
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
