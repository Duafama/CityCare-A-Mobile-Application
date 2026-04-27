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

  /// ---------------- CHECK DEPT STATUS ----------------
  Future<bool> _isDepartmentActive(String deptId) async {
    final doc = await _firestore.collection('departments').doc(deptId).get();

    final data = doc.data();
    return data?['status'] == 'active';
  }

  /// ---------------- TOGGLE USER ----------------
  Future<void> _toggleUser(
    Map<String, dynamic> userData,
    String userId,
    bool newValue,
    bool deptActive,
  ) async {
    final deptId = userData['departmentId'];

    /// ❌ BLOCK IF DEPARTMENT IS INACTIVE
    if (newValue == true && deptId != null) {
      final isDeptActive = await _isDepartmentActive(deptId);

      if (!isDeptActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Cannot activate user. Department is inactive.",
            ),
          ),
        );
        return;
      }
    }

    /// 🔥 UPDATE USER
    await _firestore
        .collection('users')
        .doc(userId)
        .update({"isActive": newValue});

    /// ❗ IF USER DISABLED → CHECK LAST USER
    if (newValue == false && deptId != null) {
      final activeUsers = await _firestore
          .collection('users')
          .where('departmentId', isEqualTo: deptId)
          .where('isActive', isEqualTo: true)
          .get();

      if (activeUsers.docs.isEmpty) {
        await _firestore
            .collection('departments')
            .doc(deptId)
            .update({"status": "inactive"});

        final cats = await _firestore
            .collection('categories')
            .where('departmentId', isEqualTo: deptId)
            .get();

        for (var c in cats.docs) {
          await c.reference.update({"status": "inactive"});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        title: const Text(
          "Manage Users",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          /// ---------------- FILTER ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Citizens"),
                    selected: selectedType == "citizen",
                    onSelected: (_) {
                      setState(() {
                        selectedType = "citizen";
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Officers"),
                    selected: selectedType == "department_officer",
                    onSelected: (_) {
                      setState(() {
                        selectedType = "department_officer";
                      });
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

          /// ---------------- USER LIST ----------------
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
                  final data = u.data() as Map<String, dynamic>;

                  final name = (data['name'] ?? "").toLowerCase().toString();

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
                    final data = u.data() as Map<String, dynamic>;

                    final isActive = data['isActive'] ?? false;
                    final deptId = data['departmentId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: deptId == null
                          ? null
                          : _firestore
                              .collection('departments')
                              .doc(deptId)
                              .get(),
                      builder: (context, deptSnap) {
                        final deptData =
                            deptSnap.data?.data() as Map<String, dynamic>?;

                        final deptActive = deptData?['status'] == 'active';

                        /// ❌ DISABLE SWITCH IF DEPT INACTIVE
                        final switchDisabled =
                            deptId != null && !deptActive && !isActive;

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
                            leading: const Icon(
                              Icons.person,
                              color: primaryBlue,
                            ),
                            title: Text(data['name'] ?? ""),
                            subtitle: Text(data['email'] ?? ""),
                            trailing: Switch(
                              value: isActive,
                              activeThumbColor: primaryBlue,
                              onChanged: switchDisabled
                                  ? null
                                  : (val) {
                                      _toggleUser(
                                        data,
                                        u.id,
                                        val,
                                        deptActive,
                                      );
                                    },
                            ),
                          ),
                        );
                      },
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
