import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();

  String? selectedDeptId;
  String status = "inactive";

  List<QueryDocumentSnapshot> departments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final catDoc =
        await _firestore.collection('categories').doc(widget.categoryId).get();

    _nameController.text = catDoc['name'];
    selectedDeptId = catDoc['departmentId'];
    status = catDoc['status'];

    final deptSnap = await _firestore.collection('departments').get();
    departments = deptSnap.docs;

    setState(() => loading = false);
  }

  /// ---------------- SAVE NAME + DEPARTMENT ----------------
  Future<void> _save() async {
    await _firestore.collection('categories').doc(widget.categoryId).update({
      "name": _nameController.text.trim(),
      "departmentId": selectedDeptId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Category updated")),
    );
  }

  /// ---------------- ACTIVATE / DEACTIVATE ----------------
  Future<void> _toggle() async {
    final newStatus = status == "active" ? "inactive" : "active";

    await _firestore.collection('categories').doc(widget.categoryId).update({
      "status": newStatus,
    });

    // update department automatically
    await _firestore
        .collection('departments')
        .doc(selectedDeptId)
        .update({"status": newStatus});

    // update officers
    final users = await _firestore
        .collection('users')
        .where('departmentId', isEqualTo: selectedDeptId)
        .get();

    for (var u in users.docs) {
      await u.reference.update({"isActive": newStatus == "active"});
    }

    setState(() => status = newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Category $newStatus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Detail"),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Category Name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _save,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDeptId,
              items: departments.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(d['name']),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedDeptId = val);
              },
              decoration: const InputDecoration(
                labelText: "Department",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status == "active" ? Colors.red : Colors.green,
              ),
              onPressed: _toggle,
              child: Text(
                status == "active" ? "Deactivate" : "Activate",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
