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
  bool isSaving = false;

  List<QueryDocumentSnapshot> departments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
    try {
      final dept = departments.firstWhere((d) => d.id == id).data()
          as Map<String, dynamic>;
      return (dept['status'] ?? "inactive") == "active";
    } catch (e) {
      return false;
    }
  }

  // ---------------- SAVE ----------------
  Future<void> _save() async {
    if (selectedDeptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select a department"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please enter a category name"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
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
        "updatedAt": FieldValue.serverTimestamp(),
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
        const SnackBar(
          content: Text("✅ Category & complaints updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  // ---------------- TOGGLE CATEGORY ----------------
  Future<void> _toggleCategory() async {
    if (selectedDeptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a department first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ❌ BLOCK IF DEPARTMENT INACTIVE
    if (!_isDeptActive(selectedDeptId!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Activate department first"),
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
      SnackBar(
        content: Text(
          status == "active"
              ? "✅ Category activated"
              : "⛔ Category deactivated",
        ),
        backgroundColor: status == "active" ? Colors.green : Colors.red,
      ),
    );
  }

  // ---------------- DEACTIVATE DEPARTMENT ----------------
  Future<void> _deactivateDepartment(String deptId) async {
    await _firestore.collection('departments').doc(deptId).update({
      "status": "inactive",
      "deactivatedAt": FieldValue.serverTimestamp(),
    });

    final users = await _firestore
        .collection('users')
        .where('departmentId', isEqualTo: deptId)
        .get();

    for (var u in users.docs) {
      await u.reference.update({"isActive": false});
    }
  }

  // ---------------- IMPROVED DROPDOWN ----------------
  Widget _buildDepartmentDropdown() {
    // Get active departments count
    final activeDepartments = departments.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return (data['status'] ?? "inactive") == "active";
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Available Departments: $activeDepartments",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedDeptId,
              isExpanded: true,
              isDense: false,
              hint: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.business_center_outlined,
                        size: 20, color: Colors.grey[400]),
                    const SizedBox(width: 12),
                    Text(
                      "Select a department",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: primaryBlue,
                  size: 24,
                ),
              ),
              iconSize: 32,
              menuMaxHeight: 400,
              items: [
                if (departments.isNotEmpty)
                  DropdownMenuItem<String>(
                    value: null,
                    enabled: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Choose department",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...departments.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final isActive = (data['status'] ?? "inactive") == "active";
                  final deptName = data['name'] ?? 'Unknown';

                  return DropdownMenuItem<String>(
                    value: d.id,
                    enabled: isActive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            isActive
                                ? Icons.apartment
                                : Icons.apartment_outlined,
                            size: 20,
                            color: isActive ? primaryBlue : Colors.grey[400],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              deptName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color:
                                    isActive ? Colors.black : Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Active",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Inactive",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                if (value == null) return;

                if (!_isDeptActive(value)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Activate department first"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  selectedDeptId = value;
                });
              },
              validator: (val) =>
                  val == null ? "Please select a department" : null,
            ),
          ),
        ),
      ],
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
        title: const Text(
          "Category Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: (status == "active" ? Colors.green : Colors.red)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (status == "active" ? Colors.green : Colors.red)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status == "active" ? Icons.check_circle : Icons.cancel,
                    color: status == "active" ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Status",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          status == "active" ? "Active" : "Inactive",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                status == "active" ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Form Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Category Information
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.category,
                            color: primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Category Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Name Field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: "e.g., Pothole Repair, Street Light Issue",
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 13),
                      prefixIcon:
                          Icon(Icons.category_outlined, color: primaryBlue),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 2: Department Assignment
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.business,
                            color: primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Assign to Department",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Department Dropdown
                  _buildDepartmentDropdown(),

                  const SizedBox(height: 32),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text("Save Changes"),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Activate/Deactivate Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: status == "active"
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        foregroundColor:
                            status == "active" ? Colors.red : Colors.green,
                        side: BorderSide(
                          color: status == "active" ? Colors.red : Colors.green,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _toggleCategory,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status == "active"
                                ? Icons.block
                                : Icons.check_circle,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status == "active"
                                ? "Deactivate Category"
                                : "Activate Category",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
