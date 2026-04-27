import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final String deptId;

  const DepartmentDetailScreen({
    super.key,
    required this.deptId,
  });

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();

  String deptStatus = "active";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartment();
  }

  Future<void> _loadDepartment() async {
    final doc =
        await _firestore.collection('departments').doc(widget.deptId).get();

    final data = doc.data() as Map<String, dynamic>?;

    _nameController.text = data?['name'] ?? "";
    deptStatus = data?['status'] ?? "active";

    setState(() => loading = false);
  }

  Future<void> _updateName() async {
    await _firestore.collection('departments').doc(widget.deptId).update({
      "name": _nameController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Name updated")),
    );
  }

  Future<void> _toggleDepartment() async {
    final newStatus = deptStatus == "active" ? "inactive" : "active";

    await _firestore.collection('departments').doc(widget.deptId).update({
      "status": newStatus,
    });

    // update users
    final users = await _firestore
        .collection('users')
        .where('departmentId', isEqualTo: widget.deptId)
        .get();

    for (var u in users.docs) {
      await u.reference.update({"isActive": newStatus == "active"});
    }

    // update categories
    final cats = await _firestore
        .collection('categories')
        .where('departmentId', isEqualTo: widget.deptId)
        .get();

    for (var c in cats.docs) {
      await c.reference.update({"status": newStatus});
    }

    setState(() => deptStatus = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Department Detail",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= NAME =================
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Department Name",
              suffixIcon: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _updateName,
              ),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  deptStatus == "active" ? Colors.red : Colors.green,
            ),
            onPressed: _toggleDepartment,
            child: Text(
              deptStatus == "active" ? "Deactivate" : "Activate",
            ),
          ),

          const SizedBox(height: 25),

          // ================= OFFICERS =================
          const Text(
            "Officers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('departmentId', isEqualTo: widget.deptId)
                .where('userType', isEqualTo: 'department_officer')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final docs = snapshot.data!.docs;

              return Column(
                children: docs.map((u) {
                  final isActive = u['isActive'] ?? false;

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(u['name'] ?? ""),
                    subtitle: const Text("Officer"),
                    trailing: Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // ================= DEPARTMENT USERS =================
          const Text(
            "Department Users",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('departmentId', isEqualTo: widget.deptId)
                .where('userType', isEqualTo: 'departmentUser')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final docs = snapshot.data!.docs;

              return Column(
                children: docs.map((u) {
                  final isActive = u['isActive'] ?? false;

                  return ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(u['name'] ?? ""),
                    subtitle: const Text("Department User"),
                    trailing: Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // ================= CATEGORIES =================
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('categories')
                .where('departmentId', isEqualTo: widget.deptId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final docs = snapshot.data!.docs;

              return Column(
                children: docs.map((c) {
                  final status = c['status'] ?? "inactive";

                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(c['name'] ?? ""),
                    trailing: Text(
                      status,
                      style: TextStyle(
                        color: status == "active" ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
