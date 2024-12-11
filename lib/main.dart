import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'introduction/splash_page.dart'; // Updated import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gene Search App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashPage(), // SplashPage as the initial page
    );
  }
}
