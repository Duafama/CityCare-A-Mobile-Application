import 'package:flutter/material.dart';

class UserDetailScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final String createdAt;
  final String profileImageUrl;

  const UserDetailScreen({
    super.key,
    required this.userName,
    this.email = "user@example.com",
    this.phone = "123-456-7890",
    this.role = "Staff",
    this.isActive = true,
    this.createdAt = "2026-01-20",
    this.profileImageUrl = "",
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  late bool _isActive;
  late String _role;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
    _role = widget.role;
  }

  void _updateUser() {
    // UI-only: Show dialog for successful update
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Success",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("User information updated successfully."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          "Manage Users",
          style: const TextStyle(
            color: Colors.white, // White text
            fontWeight: FontWeight.bold, // Bold font
            fontSize: 20, // Slightly larger
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---- Profile Image ----
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.profileImageUrl.isNotEmpty
                      ? NetworkImage(widget.profileImageUrl)
                      : null,
                  backgroundColor: primaryBlue,
                  child: widget.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              /// ---- Name ----
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              /// ---- Email ----
              Text(
                "Email: ${widget.email}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),

              /// ---- Phone ----
              Text(
                "Phone: ${widget.phone}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),

              /// ---- Created At ----
              Text(
                "Created At: ${widget.createdAt}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              /// ---- Status Switch ----
              SwitchListTile(
                title: const Text("Active"),
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
                activeThumbColor: primaryBlue,
              ),
              const SizedBox(height: 16),

              /// ---- Role Dropdown ----
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Admin", child: Text("Admin")),
                  DropdownMenuItem(
                    value: "Department Officer",
                    child: Text("Department Officer"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _role = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              /// ---- Save Button ----
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _updateUser,
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
