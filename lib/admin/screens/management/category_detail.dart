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

  // ---------------- LOAD ----------------
  Future<void> _loadData() async {
    final catDoc =
        await _firestore.collection('categories').doc(widget.categoryId).get();

    final data = catDoc.data() as Map<String, dynamic>;

    _nameController.text = data['name'] ?? "";
    selectedDeptId = data['departmentId'];
    status = data['status'] ?? "inactive";

    final deptSnap = await _firestore.collection('departments').get();
    departments = deptSnap.docs;

    setState(() => loading = false);
  }

  bool _isDeptActive(String id) {
    final dept = departments.firstWhere((d) => d.id == id).data()
        as Map<String, dynamic>;
    return (dept['status'] ?? "inactive") == "active";
  }

  // ---------------- SAVE ----------------
  Future<void> _save() async {
    if (selectedDeptId == null) return;

    final batch = _firestore.batch();

    // 1. Get selected department data
    final deptDoc =
        await _firestore.collection('departments').doc(selectedDeptId).get();

    final deptData = deptDoc.data() as Map<String, dynamic>;
    final deptName = deptData['name'];

    // 2. Update category
    final categoryRef =
        _firestore.collection('categories').doc(widget.categoryId);

    batch.update(categoryRef, {
      "name": _nameController.text.trim(),
      "departmentId": selectedDeptId,
      "departmentName": deptName,
    });

    // 3. Update all complaints linked to this category
    final complaintSnap = await _firestore
        .collection('complaints')
        .where('categoryId', isEqualTo: widget.categoryId)
        .get();

    for (var doc in complaintSnap.docs) {
      batch.update(doc.reference, {
        "departmentId": selectedDeptId,
        "departmentName": deptName,
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Category & complaints updated")),
    );

    setState(() {});
  }

  // ---------------- TOGGLE CATEGORY ----------------
  Future<void> _toggleCategory() async {
    if (selectedDeptId == null) return;

    // ❌ BLOCK IF DEPARTMENT INACTIVE
    if (!_isDeptActive(selectedDeptId!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Activate department first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newStatus = status == "active" ? "inactive" : "active";

    await _firestore
        .collection('categories')
        .doc(widget.categoryId)
        .update({"status": newStatus});

    setState(() => status = newStatus);

    // if last active category → deactivate department
    if (newStatus == "inactive") {
      final activeCats = await _firestore
          .collection('categories')
          .where('departmentId', isEqualTo: selectedDeptId)
          .where('status', isEqualTo: "active")
          .get();

      if (activeCats.docs.isEmpty) {
        await _deactivateDepartment(selectedDeptId!);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Category $newStatus")),
    );
  }

  // ---------------- DEACTIVATE DEPARTMENT ----------------
  Future<void> _deactivateDepartment(String deptId) async {
    await _firestore.collection('departments').doc(deptId).update({
      "status": "inactive",
    });

    final users = await _firestore
        .collection('users')
        .where('departmentId', isEqualTo: deptId)
        .get();

    for (var u in users.docs) {
      await u.reference.update({"isActive": false});
    }
  }

  // ---------------- DROPDOWN ----------------
  Widget _departmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDeptId,
          isExpanded: true,
          hint: const Text("Select Department"),
          items: departments.map((d) {
            final data = d.data() as Map<String, dynamic>;
            final isActive = (data['status'] ?? "inactive") == "active";

            return DropdownMenuItem(
              value: d.id,

              // ❌ DISABLE INACTIVE DEPARTMENTS
              enabled: isActive,

              child: Row(
                children: [
                  Icon(
                    Icons.apartment,
                    size: 18,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['name'],
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  if (!isActive)
                    const Text(
                      "Inactive",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    )
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            if (!_isDeptActive(value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Activate department first"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            setState(() {
              selectedDeptId = value;
            });
          },
        ),
      ),
    );
  }

  // ---------------- UI ----------------
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
        title: const Text("Category Detail"),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Category Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _save,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _departmentDropdown(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      status == "active" ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _toggleCategory,
                child: Text(
                  status == "active" ? "Deactivate" : "Activate",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
