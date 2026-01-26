import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:city_care/admin/app_routes.dart';


// ADD THESE IMPORTS:
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const CityCareApp());
}

class CityCareApp extends StatelessWidget {
  const CityCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A), // Royal Blue
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // ADMIN ROUTES (THIS WAS MISSING)
  ...AppRoutes.routes,
      },
    );
  }
}