import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:city_care/user/welcome_screen.dart';
import 'package:city_care/user/dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state - jab tak Firebase check kar raha hai
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData) {
          print('✅ User logged in: ${snapshot.data?.email}');
          // Direct dashboard, no navigation needed
          return const DashboardScreen();
        } else {
          print('👤 No user logged in');
          // Direct welcome screen, no navigation needed
          return const WelcomeScreen();
        }
      },
    );
  }
}