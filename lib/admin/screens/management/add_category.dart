import 'package:flutter/material.dart';
import 'package:city_care/services/category_service.dart';
import 'package:city_care/services/department_service.dart';
import 'package:city_care/models/department.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final CategoryService _categoryService = CategoryService();
  final DepartmentService _departmentService = DepartmentService();

  List<Department> departments = [];
  String? selectedDeptId;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ---------------- VALIDATION ----------------
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter category name";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }

  // ---------------- LOAD ----------------
  Future<void> _loadDepartments() async {
    try {
      final data = await _departmentService.getAllDepartments();

      setState(() {
        departments = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading departments: $e")),
      );
    }
  }

  // ---------------- SUBMIT ----------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDeptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select a department"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await _categoryService.addCategory(
        name: _nameController.text.trim(),
        departmentId: selectedDeptId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Category created successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => saving = false);
  }

  // ---------------- IMPROVED DROPDOWN ----------------
  Widget _buildDepartmentDropdown() {
    // Get active departments count
    final activeDepartments =
        departments.where((d) => d.status == "active").length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with count badge
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

        // Custom styled dropdown
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
              isExpanded: true, // Only ONE isExpanded here
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
              // Make dropdown scrollable by limiting height
              menuMaxHeight: 400,
              // REMOVED duplicate isExpanded from here
              items: [
                // Optional: Add a header item (disabled)
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
                // Department items
                ...departments.map((dept) {
                  final isActive = dept.status == "active";

                  return DropdownMenuItem<String>(
                    value: dept.id,
                    enabled: isActive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          // Status indicator
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Department icon
                          Icon(
                            isActive
                                ? Icons.apartment
                                : Icons.apartment_outlined,
                            size: 20,
                            color: isActive ? primaryBlue : Colors.grey[400],
                          ),
                          const SizedBox(width: 12),

                          // Department name
                          Expanded(
                            child: Text(
                              dept.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color:
                                    isActive ? Colors.black : Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Status badge
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

                final dept = departments.firstWhere((d) => d.id == value);

                if (dept.status != "active") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "❌ This department is inactive. Activate it first to add categories.",
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
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
          "Add New Category",
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
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryBlue.withOpacity(0.08),
                    primaryBlue.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryBlue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Categories help organize complaints by type. Each category must be assigned to an active department.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main form card
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
              child: Form(
                key: _formKey,
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
                      validator: _validateName,
                    ),

                    const SizedBox(height: 32),

                    // Section 2: Department Selection
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

                    // Submit Button
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
                        onPressed: saving ? null : _submit,
                        child: saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text("Create Category"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
