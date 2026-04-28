import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADD THIS IMPORT
import 'package:city_care/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ADD THIS
  final UserService _userService = UserService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Stream of auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String paymentMethod,
    required double registrationFee,
    String? profileImageUrl,
    String? departmentId, // 🔥 NEW: Optional parameter (null for citizens
  }) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        // 2. Update user profile with name
        await user.updateDisplayName(name);
        await user.reload();

        // 3. Save additional data to Firestore
        String? error = await _userService.saveUserData(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          paymentMethod: paymentMethod,
          registrationFee: registrationFee,
          profileImageUrl: profileImageUrl,
          departmentId: departmentId, // 🔥 NEW: Pass departmentId
        );

        if (error != null) {
          // If Firestore save fails, delete the auth user to maintain consistency
          await user.delete();
          return {
            'success': false,
            'error': error,
          };
        }

        // 4. Send email verification (optional)
        await user.sendEmailVerification();

        return {
          'success': true,
          'user': user,
        };
      }

      return {
        'success': false,
        'error': 'Registration failed: User not created',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please login instead.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return {
        'success': false,
        'error': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: $e',
      };
    }
  }

//Creating department Officer
  Future<Map<String, dynamic>> createDepartmentOfficer({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String departmentId,
  }) async {
    try {
      // 🔥 IMPORTANT: isolate auth session
      final secondaryAuth = FirebaseAuth.instanceFor(
        app: FirebaseAuth.instance.app,
      );

      // Create officer WITHOUT affecting admin session
      UserCredential result =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name);

        await _userService.saveUserData(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          paymentMethod: "N/A",
          registrationFee: 0.0,
          profileImageUrl: null,
          departmentId: departmentId,
        );

        // 🔥 IMPORTANT: logout secondary auth only
        await secondaryAuth.signOut();

        return {"success": true, "user": user};
      }

      return {"success": false, "error": "User creation failed"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // Login method
  // Login method
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update last login in Firestore
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      // 🔥 FETCH ROLE + DEPARTMENT ID (ONLY ADDITION)
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        return {
          'success': false,
          'error': 'User profile not found',
        };
      }

      Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map);

      // 🔴 NEW: ACTIVE CHECK
      final isActive = data['isActive'] ?? true; // default true if not set

      if (!isActive) {
        await _auth.signOut();
        return {
          'success': false,
          'error': 'Your account has been deactivated. Contact admin.',
        };
      }

      return {
        'success': true,
        'user': result.user,
        'role': data['userType'],
        'departmentId': data['departmentId'],
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      return {
        'success': false,
        'error': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: $e',
      };
    }
  }

  //
  // Add this method in AuthService class
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {'success': true, 'message': 'Password reset email sent!'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message};
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
