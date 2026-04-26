import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_detail.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedType = "citizen";
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title:
            const Text("Manage Users", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          /// ---------------- TYPE FILTER ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Citizens"),
                    selected: selectedType == "citizen",
                    onSelected: (_) {
                      setState(() => selectedType = "citizen");
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Officers"),
                    selected: selectedType == "department_officer",
                    onSelected: (_) {
                      setState(() => selectedType = "department_officer");
                    },
                  ),
                ),
              ],
            ),
          ),

          /// ---------------- SEARCH ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() => search = val.toLowerCase());
              },
            ),
          ),

          const SizedBox(height: 10),

          /// ---------------- LIST ----------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('userType', isEqualTo: selectedType)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((u) {
                  final name = (u['name'] ?? "").toLowerCase();
                  return name.contains(search);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];

                    final isActive = u['isActive'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(
                                userId: u.id,
                              ),
                            ),
                          );
                        },
                        leading: const Icon(Icons.person, color: primaryBlue),
                        title: Text(u['name'] ?? ""),
                        subtitle: Text(u['email'] ?? ""),
                        trailing: Switch(
                          value: isActive,
                          activeColor: primaryBlue,
                          onChanged: (val) async {
                            await _firestore
                                .collection('users')
                                .doc(u.id)
                                .update({"isActive": val});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
