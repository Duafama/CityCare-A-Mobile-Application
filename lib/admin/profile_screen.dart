import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:city_care/services/auth_service.dart';
import 'package:city_care/services/user_service.dart';
import 'package:city_care/services/cloudinary_service.dart';

import 'admin_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 3;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  File? profileImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isSaving = false;

  /// Pick Image
  Future pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(ctx);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(ctx);
                pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Save Changes
  Future<void> _saveChanges(String uid) async {
    setState(() => isSaving = true);

    String? imageUrl;

    /// Upload image if changed
    if (profileImage != null) {
      imageUrl = await CloudinaryService.uploadImage(profileImage!);

      if (imageUrl != null) {
        await _userService.updateProfileImage(uid, imageUrl);
      }
    }

    await _userService.updateUserProfile(uid, {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => isSaving = false);

    _showSuccessDialog();
  }

  /// Logout with confirmation
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.logout();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Profile updated successfully"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // ☰ menu icon color
        ),
      ),
      drawer: adminDrawer(context),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (nameController.text.isEmpty) {
            nameController.text = data['name'] ?? '';
          }

          if (phoneController.text.isEmpty) {
            phoneController.text = data['phone'] ?? '';
          }

          String email = data['email'] ?? '';
          String role = data['userType'] ?? '';
          String imageUrl = data['profileImageUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Profile Image
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryBlue.withOpacity(0.2),
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null)
                            as ImageProvider?,
                    child: profileImage == null && imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 60, color: primaryBlue)
                        : null,
                  ),
                ),

                const SizedBox(height: 20),

                _buildTextField("Name", nameController, Icons.person),

                const SizedBox(height: 12),

                _buildTextField("Phone", phoneController, Icons.phone),

                const SizedBox(height: 12),

                _buildReadOnly("Email", email),

                const SizedBox(height: 12),

                _buildReadOnly("Role", role),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isSaving ? null : () => _saveChanges(user.uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white, // 👈 text + icon color
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes"),
                ),

                const SizedBox(height: 10),

                OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: adminBottomNav(context, _currentIndex),
    );
  }

  /// Editable field
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Read-only field
  Widget _buildReadOnly(String label, String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
