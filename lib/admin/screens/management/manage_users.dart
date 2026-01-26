import 'package:flutter/material.dart';
import 'user_detail.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  // Sample user data
  final List<Map<String, dynamic>> users = [
    {
      "name": "Alice Johnson",
      "email": "alice@example.com",
      "phone": "123-456-7890",
      "role": "Admin",
      "active": true,
      "createdAt": "2026-01-15",
      "profileImageUrl": "",
    },
    {
      "name": "Bob Smith",
      "email": "bob@example.com",
      "phone": "987-654-3210",
      "role": "Department Officer",
      "active": false,
      "createdAt": "2026-01-20",
      "profileImageUrl": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        title: const Text(
          "Manage Users",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// ---------------- Body ----------------
      body: users.isEmpty
          ? const Center(
              child: Text(
                "No users available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: primaryBlue,
                      backgroundImage:
                          (user['profileImageUrl'] ?? '').isNotEmpty
                          ? NetworkImage(user['profileImageUrl'])
                          : null,
                      child: (user['profileImageUrl'] ?? '').isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                    title: Text(
                      user['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "${user['email']} - ${user['role']}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Switch(
                      value: user['active'],
                      onChanged: (val) {
                        setState(() {
                          user['active'] = val;
                        });
                      },
                      activeThumbColor: primaryBlue,
                    ),
                    onTap: () {
                      // Open full UserDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailScreen(
                            userName: user['name'],
                            email: user['email'],
                            phone: user['phone'],
                            role: user['role'],
                            isActive: user['active'],
                            createdAt: user['createdAt'],
                            profileImageUrl: user['profileImageUrl'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
