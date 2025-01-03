import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/home_page.dart'; // Home page after sign-in
import 'forgot_password_page.dart'; // Forgot password page

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sign in to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Colors.blueGrey[700]),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Colors.blueGrey[700]),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => signIn(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(color:Colors.white,fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blueGrey[700], fontSize: 16),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/sign-up'); // Navigate to sign-up
              },
              child: Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.blueGrey[700], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
