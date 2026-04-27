import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:city_care/user/welcome_screen.dart';
import 'package:city_care/user/dashboard_screen.dart';
import 'package:city_care/admin/admin_dashboard.dart';
import 'package:city_care/department/department_dashboard.dart';

import 'package:provider/provider.dart';
import '../providers/department_provider.dart';

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

              return Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<DepartmentProvider>().setDepartment(
                      departmentId!,
                      'officer',
                    );
                  });

                  return const DepartmentDashboard();
                },
              );
            }

            if (userType == 'departmentUser') {
              if (departmentId == null || departmentId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text("Department not assigned")),
                );
              }

              return Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<DepartmentProvider>().setDepartment(
                      departmentId!,
                      'user',
                    );
                  });

                  return const DepartmentDashboard();
                },
              );
            }

            return const DashboardScreen();
          },
        );
      },
    );
  }
}