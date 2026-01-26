import 'package:flutter/material.dart';
import '../../admin_navigation.dart';
import 'department_report_screen.dart';

class ReportsMenuScreen extends StatefulWidget {
  const ReportsMenuScreen({super.key});

  @override
  State<ReportsMenuScreen> createState() => _ReportsMenuScreenState();
}

class _ReportsMenuScreenState extends State<ReportsMenuScreen> {
  final int _currentIndex = 2;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final List<String> departments = [
    "Sanitation",
    "Roads",
    "Water Supply",
    "Electricity",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),

      /// ---------------- Drawer ----------------
      drawer: adminDrawer(context),

      /// ---------------- Body ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- Section: Overall Report ----
            const Text(
              "Overall Report",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            reportCard(
              title: "Overall Report",
              icon: Icons.bar_chart,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DepartmentReportScreen(department: "Overall"),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            /// ---- Section: Department Reports ----
            const Text(
              "Department Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            /// One department per card
            Column(
              children: departments
                  .map(
                    (dept) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: reportCard(
                        title: dept,
                        icon: Icons.apartment,
                        color: primaryBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DepartmentReportScreen(department: dept),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),

      /// ---------------- Bottom Navigation ----------------
      bottomNavigationBar: adminBottomNav(context, _currentIndex),
    );
  }

  /// ---------------- Report Card Widget ----------------
  Widget reportCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
