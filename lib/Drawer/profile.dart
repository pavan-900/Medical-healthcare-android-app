import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user's name and email
            Text(
              'Name: ${user?.displayName ?? "Not Available"}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Email: ${user?.email ?? "Not Available"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Conditional button
            user?.email != null
                ? ElevatedButton(
              onPressed: () async {
                // Log out the user
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Log Out'),
            )
                : ElevatedButton(
              onPressed: () {
                // Navigate to the Sign-In page
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

