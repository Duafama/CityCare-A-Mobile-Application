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
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? profileImage;
  bool isSaving = false;

  bool _initialized = false;

  // Validation error messages
  String? _nameError;
  String? _phoneError;

  /// ---------------- VALIDATION METHODS ----------------
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }

    // Remove all whitespace for checking
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return "Name cannot be empty";
    }

    // Check if name contains only letters and spaces
    final RegExp nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(trimmedValue)) {
      return "Name should only contain letters and spaces";
    }

    // Check minimum length
    if (trimmedValue.length < 2) {
      return "Name must be at least 2 characters long";
    }

    // Check maximum length
    if (trimmedValue.length > 50) {
      return "Name must be less than 50 characters";
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number cannot be empty";
    }

    // Remove all non-digit characters for validation
    final String cleanedPhone = value.replaceAll(RegExp(r'\D'), '');

    // Check if phone contains only digits
    final RegExp phoneRegex = RegExp(r'^\d+$');
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return "Phone number should only contain numbers";
    }

    // Check if phone is exactly 11 digits
    if (cleanedPhone.length != 11) {
      return "Phone number must be exactly 11 digits";
    }

    // Optional: Check if phone starts with valid prefix (e.g., 03 for Pakistan)
    if (!cleanedPhone.startsWith('03')) {
      return "Phone number should start with '03'";
    }

    return null;
  }

  /// ---------------- IMAGE PICK ----------------
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

  /// ---------------- SAVE PROFILE ----------------
  Future<void> _saveChanges(String uid) async {
    // Validate fields before saving
    final name = nameController.text;
    final phone = phoneController.text;

    setState(() {
      _nameError = _validateName(name);
      _phoneError = _validatePhone(phone);
    });

    // If there are validation errors, don't save
    if (_nameError != null || _phoneError != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the validation errors before saving"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    String? imageUrl;

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

    // Show success dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Profile updated successfully"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// ---------------- LOGOUT ----------------
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.logout();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  /// ---------------- SAFE CONTROLLER FILL ----------------
  void _fillControllers(Map<String, dynamic> data) {
    nameController.text = data['name'] ?? '';
    phoneController.text = data['phone'] ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Session expired. Please login again."),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: AppBar(
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: primaryBlue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
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

            /// Fill controllers ONLY ONCE
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_initialized) {
                _fillControllers(data);
                _initialized = true;
              }
            });

            final email = data['email'] ?? '';
            final role = data['userType'] ?? '';
            final imageUrl = data['profileImageUrl'] ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// PROFILE IMAGE
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: primaryBlue.withOpacity(0.2),
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : (imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null) as ImageProvider?,
                      child: profileImage == null && imageUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 60, color: primaryBlue)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// NAME FIELD WITH VALIDATION
                  _buildTextField(
                    label: "Name",
                    controller: nameController,
                    icon: Icons.person,
                    errorText: _nameError,
                    onChanged: (value) {
                      setState(() {
                        _nameError = _validateName(value);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// PHONE FIELD WITH VALIDATION
                  _buildTextField(
                    label: "Phone",
                    controller: phoneController,
                    icon: Icons.phone,
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        _phoneError = _validatePhone(value);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildReadOnly("Email", email),

                  const SizedBox(height: 12),

                  _buildReadOnly("Role", role),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isSaving ? null : () => _saveChanges(user.uid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
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
        bottomNavigationBar: adminBottomNav(context, 3),
      ),
    );
  }

  /// ---------------- UI HELPERS ----------------
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.white,
        errorText: errorText,
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildReadOnly(String label, String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
