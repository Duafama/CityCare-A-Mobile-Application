import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatefulWidget {
  final String? userId;

  const UserDetailScreen({super.key, this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? user;
  Map<String, dynamic>? department;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /// ---------------- FORMAT DATE ----------------
  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "N/A";

    DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return "Invalid date";
    }

    return DateFormat('EEEE | yyyy-MM-dd | HH:mm:ss').format(dateTime);
  }

  /// ---------------- LOAD USER + DEPARTMENT ----------------
  Future<void> _loadUser() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();

    user = doc.data();

    if (user?['departmentId'] != null) {
      final deptDoc = await _firestore
          .collection('departments')
          .doc(user!['departmentId'])
          .get();

      department = deptDoc.data();
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isOfficer = user?['userType'] == "department_officer";

    final isActive = user?['isActive'] == true;
    final deptActive = department?['status'] == "active";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white),
        ),
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
              ),
            ],
          ),
          child: Column(
            children: [
              /// ---------------- PROFILE ----------------
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryBlue,
                backgroundImage:
                    (user?['profileImageUrl'] ?? "").toString().isNotEmpty
                        ? NetworkImage(user!['profileImageUrl'])
                        : null,
                child: (user?['profileImageUrl'] ?? "").toString().isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),

              const SizedBox(height: 16),

              Text(
                user?['name'] ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// ---------------- USER STATUS ----------------
              _statusBadge(
                isActive ? "Active" : "Inactive",
                isActive ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 10),

              /// ---------------- DEPARTMENT STATUS ----------------
              if (isOfficer)
                _statusBadge(
                  deptActive ? "Department Active" : "Department Inactive",
                  deptActive ? Colors.green : Colors.red,
                ),

              const SizedBox(height: 20),

              /// ---------------- INFO ----------------
              _infoTile(Icons.email, "Email", user?['email']),
              _infoTile(Icons.phone, "Phone", user?['phone']),
              _infoTile(Icons.person, "Role", user?['userType']),
              _infoTile(
                Icons.date_range,
                "Created At",
                formatTimestamp(user?['createdAt']),
              ),

              if (isOfficer)
                _infoTile(
                  Icons.apartment,
                  "Department",
                  department?['name'] ?? "N/A",
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- STATUS BADGE ----------------
  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ---------------- INFO TILE ----------------
  Widget _infoTile(IconData icon, String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value ?? "N/A"}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
