import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:city_care/admin/app_routes.dart';
import 'package:city_care/department/department_routes.dart';
import 'package:city_care/admin/admin_dashboard.dart';
import 'package:city_care/department/department_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
//
import 'package:city_care/services/payment_service.dart'; // ✅ Add this
import 'package:provider/provider.dart';
import 'providers/department_provider.dart';

// ADD THESE IMPORTS:
import 'user/auth_wrapper.dart';
import 'user/login_screen.dart';
import 'user/register_screen.dart';
import 'user/dashboard_screen.dart';
import 'user/forgot_password_screen.dart';
import '../services/AIService.dart'; // only for isCommentSafe (profanity check)

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // ✅ ADD THIS

  await Firebase.initializeApp();
  await PaymentService.initialize();
  await AIService.initialize(); // 👈 Add this line

  print("🔥 APP STARTED");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DepartmentProvider(),
        ),
      ],
      child: const CityCareApp(),
    ),
  );
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
        // '/': (context) => WelcomeScreen(),
        '/': (context) => const AuthWrapper(), // 👈 YEH HONA CHAHIYE
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/department-dashboard': (context) => DepartmentDashboard(),
        // ADMIN ROUTES
        ...AppRoutes.routes,
        //DEPARTMENT ROUTES
        ...DepartmentRoutes.routes,
      },
    );
  }
}
