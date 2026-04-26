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

  /// ---------------- LOAD DATA ----------------
  Future<void> _loadDepartment() async {
    final doc =
        await _firestore.collection('departments').doc(widget.deptId).get();

    _nameController.text = doc['name'];
    deptStatus = doc['status'] ?? "active";
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadDepartment();
  }

  /// ---------------- UPDATE NAME ----------------
  Future<void> _updateName() async {
    await _firestore.collection('departments').doc(widget.deptId).update({
      "name": _nameController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Name updated"),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// ---------------- TOGGLE STATUS ----------------
  Future<void> _toggleDepartment() async {
    final newStatus = deptStatus == "active" ? "inactive" : "active";

    await _firestore.collection('departments').doc(widget.deptId).update({
      "status": newStatus,
    });

    // officers update
    final users = await _firestore
        .collection('users')
        .where('departmentId', isEqualTo: widget.deptId)
        .get();

    for (var u in users.docs) {
      await u.reference.update({
        "isActive": newStatus == "active",
      });
    }

    // categories update
    final cats = await _firestore
        .collection('categories')
        .where('departmentId', isEqualTo: widget.deptId)
        .get();

    for (var c in cats.docs) {
      await c.reference.update({
        "status": newStatus,
      });
    }

    setState(() {
      deptStatus = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Department $newStatus"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ---------------- NAME EDIT ----------------
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

            const SizedBox(height: 20),

            /// ---------------- STATUS BUTTON ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      deptStatus == "active" ? Colors.red : Colors.green,
                ),
                onPressed: _toggleDepartment,
                child: Text(
                  deptStatus == "active" ? "Deactivate" : "Activate",
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ---------------- OFFICERS LIST ----------------
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Officers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('departmentId', isEqualTo: widget.deptId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  if (users.isEmpty) {
                    return const Center(child: Text("No officers found"));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final u = users[index];

                      final isActive = u['isActive'] ?? true;

                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(u['name'] ?? "Unknown"),
                        trailing: Text(
                          isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
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
      ),
    );
  }
}
