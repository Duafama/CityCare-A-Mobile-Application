import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:city_care/user/welcome_screen.dart';
import 'package:city_care/user/dashboard_screen.dart';
import 'package:city_care/admin/admin_dashboard.dart';
import 'package:city_care/department/department_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ NO USER LOGGED IN
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {

            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!roleSnapshot.hasData || roleSnapshot.data == null) {
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            final data =
                roleSnapshot.data!.data() as Map<String, dynamic>;

            String userType = data['userType'] ?? 'citizen';
            String? departmentId = data['departmentId'];

            print("✅ userType detected: $userType");

            if (userType == 'admin') {
              return const AdminDashboard();
            }

            if (userType == 'department_officer') {
              if (departmentId == null || departmentId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text("Department not assigned")),
                );
              }

              return const DepartmentDashboard();
            }

            return const DashboardScreen();
          },
        );
      },
    );
  }
}