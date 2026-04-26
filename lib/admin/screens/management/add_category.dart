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
  final _nameController = TextEditingController();

  final CategoryService _categoryService = CategoryService();
  final DepartmentService _departmentService = DepartmentService();

  List<Department> _departments = [];
  String? _selectedDepartmentId;
  bool _loading = true;
  bool _saving = false;

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
      return "Enter name";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }

  // ---------------- LOAD DEPARTMENTS ----------------

  void _loadDepartments() async {
    final data = await _departmentService.getInactiveDepartments();
    setState(() {
      _departments = data;
      _loading = false;
    });
  }

  // ---------------- SUBMIT ----------------

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a department")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _categoryService.addCategory(
        name: _nameController.text.trim(),
        departmentId: _selectedDepartmentId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category added successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _saving = false);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Add Category",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Category Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Category Name
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Department Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDepartmentId,
                  items: _departments.map((d) {
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartmentId = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Select Department",
                    prefixIcon: Icon(Icons.apartment, color: primaryBlue),
                  ),
                  validator: (value) =>
                      value == null ? "Select department" : null,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Category",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
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
