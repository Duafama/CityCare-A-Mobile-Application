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
    print("BUTTON CLICKED"); // debug

    if (!_formKey.currentState!.validate()) return;

    if (selectedDeptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select a department"),
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
          content: Text("Category created successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e"); // important debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => saving = false);
  }

  // ---------------- DROPDOWN ----------------
  Widget _departmentDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDeptId,
      isExpanded: true,
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        labelText: "Select Department",
        prefixIcon: const Icon(Icons.apartment, color: primaryBlue),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: departments.map((dept) {
        final isActive = dept.status == "active";

        return DropdownMenuItem<String>(
          value: dept.id,
          enabled: isActive,
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: isActive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dept.name,
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              Text(
                isActive ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        final dept = departments.firstWhere((d) => d.id == value);

        if (dept.status != "active") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This department is inactive. Activate it first."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          selectedDeptId = value;
        });
      },
      validator: (val) => val == null ? "Select department" : null,
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
          "Add Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

          // ✅ FIXED: FORM ADDED HERE
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Category Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Category Name",
                    prefixIcon: Icon(Icons.category, color: primaryBlue),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Department Selection",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _departmentDropdown(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: saving ? null : _submit,
                    child: saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Category",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
