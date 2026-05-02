import 'package:cloud_firestore/cloud_firestore.dart';


class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Save user data to Firestore
  Future<String?> saveUserData({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String paymentMethod,
    required double registrationFee,
    String? profileImageUrl, 
    String? departmentId, //  Department ID (null for citizens)
  }) async {
    try {
      // Create user document in 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'paymentMethod': paymentMethod,
        'registrationFee': registrationFee,
        'userType': departmentId == null
            ? 'citizen'
            : 'department_officer', //  Auto-detect
        'departmentId':
            departmentId, //  null for citizens, ID for officers
        'isActive': departmentId == null ? true : false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'profileImageUrl': profileImageUrl ?? '',
      });

      // Also create a payment record
      await _firestore.collection('payments').add({
        'userId': uid,
        'userEmail': email,
        'userName': name,
        'amount': registrationFee,
        'paymentMethod': paymentMethod,
        'paymentType': 'registration',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return 'Error saving user data: $e';
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user: $e');
      return false;
    }
  }

  // Profile image update karne ka method
  Future<String?> updateProfileImage(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'Error updating profile image: $e';
    }
  }

// Update user profile
  Future<String?> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
      return null;
    } catch (e) {
      return 'Error updating profile: $e';
    }
  }

// 🔥  Update user type (citizen to department officer)
  Future<String?> updateUserType(String uid, String userType,
      {String? departmentId}) async {
    try {
      Map<String, dynamic> updates = {
        'userType': userType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (departmentId != null) {
        updates['departmentId'] = departmentId;
      } else if (userType == 'citizen') {
        updates['departmentId'] = null; // dpt id of citizens null
      }

      await _firestore.collection('users').doc(uid).update(updates);
      return null;
    } catch (e) {
      return 'Error updating user type: $e';
    }
  }

  // Check if user is department officer
  Future<bool> isDepartmentOfficer(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        String userType = doc.get('userType') ?? 'citizen';
        return userType == 'department_officer';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //  Get department ID of user
  Future<String?> getDepartmentId(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.get('departmentId');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
