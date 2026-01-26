import 'package:flutter/material.dart';
import 'add_department.dart';
import 'department_detail.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() =>
      _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final List<Map<String, dynamic>> departments = [
    {"name": "Sanitation", "date": "2026-01-20"},
    {"name": "Roads", "date": "2026-01-21"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        title: const Text(
          "Manage Departments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// ---------------- FAB ----------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDepartmentScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// ---------------- Body ----------------
      body: departments.isEmpty
          ? const Center(
              child: Text(
                "No departments available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final dept = departments[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// ---- Icon ----
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.apartment, color: primaryBlue),
                      ),

                      const SizedBox(width: 16),

                      /// ---- Info ----
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Created on ${dept['date']}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ---- Actions ----
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DepartmentDetailScreen(name: dept['name']),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// ---------------- Delete Confirmation ----------------

  /// ---------------- Delete Confirmation ----------------
  /// ---------------- Delete Confirmation (UI-only) ----------------
  void _confirmDelete(BuildContext context, int index) {
    final deletedName = departments[index]['name']; // just for message

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Department",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this department? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // close the dialog only

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$deletedName deleted successfully"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
