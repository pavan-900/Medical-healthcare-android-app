import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'introduction/splash_page.dart'; // Splash page
import 'introduction/welcome_page.dart'; // Welcome page
import 'introduction/first.dart'; // First Introduction page
import 'introduction/second.dart'; // Second Introduction page
import 'introduction/third_page.dart'; // Third Introduction page
import 'introduction/signupPromptpage.dart'; // Final Introduction page
import 'auth/sign-in_page.dart'; // Sign-In page
import 'auth/sign-up_page.dart'; // Sign-Up page
import 'auth/forgot_password_page.dart'; // Forgot Password page
import 'pages/home_page.dart'; // Home page
import 'pages/references_selection_page.dart'; // New References Selection Page
import 'pages/pubtutor_references_page.dart'; // New PubTutor References Page
import 'pages/references_page.dart'; // Existing PharmGKB References Page

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashWrapper(),
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/sign-in': (context) => SignInPage(),
        '/sign-up': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/airdrop': (context) => AirdropPage(),
        '/third': (context) => ThirdPage(),
        '/signup-prompt': (context) => SignupPromptPage(),
        '/references-selection': (context) => ReferencesSelectionPage(
          geneSymbol: '', // Placeholder, pass dynamically when navigating
          pharmGKBId: '', // Placeholder, pass dynamically when navigating
          currentCondition: '', // Placeholder for current condition
          otherConditions: [], // Placeholder for other conditions
        ),
        '/pharmgkb-references': (context) => ReferencesPage(
          geneSymbol: '', // Placeholder, pass dynamically when navigating
          pharmGKBId: '', // Placeholder, pass dynamically when navigating
          currentCondition: '', // Placeholder for current condition
          otherConditions: [], // Placeholder for other conditions
        ),
        '/pubtutor-references': (context) => PubTutorReferencesPage(
          geneSymbol: '', // Placeholder, pass dynamically when navigating
          currentCondition: '', // Placeholder for current condition
          otherConditions: [], // Placeholder for other conditions
        ),
      },
    );
  }
}

/// Wrapper to handle Splash Screen navigation
class SplashWrapper extends StatefulWidget {
  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(Duration(seconds: 3)); // Splash screen duration
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already signed in
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not signed in, navigate to WelcomePage
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashPage(); // Displays the SplashPage
  }
}
