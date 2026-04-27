import 'package:flutter/material.dart';
import '../../admin_navigation.dart';
import '../../../models/department.dart';
import 'admin_report_service.dart';
import 'report_widgets.dart';
import 'admin_overall_report.dart';
import 'department_report_screen.dart';

class ReportsMenuScreen extends StatefulWidget {
  const ReportsMenuScreen({super.key});

  @override
  State<ReportsMenuScreen> createState() => _ReportsMenuScreenState();
}

class _ReportsMenuScreenState extends State<ReportsMenuScreen> {
  final int _currentIndex = 2;

  List<Department> departments = [];
  Map<String, int> deptComplaintCounts = {}; // deptId → total complaints
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final service = AdminReportService();
      final depts = await service.getAllDepartments();
      final allComplaints = await service.getAllComplaints();

      // Count complaints per department
      final Map<String, int> counts = {};
      for (final c in allComplaints) {
        if (c.departmentId != null) {
          counts[c.departmentId!] =
              (counts[c.departmentId!] ?? 0) + 1;
        }
      }

      setState(() {
        departments = depts;
        deptComplaintCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDepts = departments.length;
    final totalComplaints =
        deptComplaintCounts.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: kLightGrey,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Reports",
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryBlue,
        elevation: 0,
      ),

      drawer: adminDrawer(context),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── AT-A-GLANCE STATS ─────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ReportStatCard(
                        label: "Total Complaints",
                        value: totalComplaints.toString(),
                        icon: Icons.bar_chart,
                        color: kPrimaryBlue,
                      ),
                      ReportStatCard(
                        label: "Departments",
                        value: totalDepts.toString(),
                        icon: Icons.apartment,
                        color: const Color(0xFF1E88E5),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── OVERALL REPORT ────────────────────────────
                  const SectionHeader(
                    title: "Overall Report",
                    subtitle:
                        "System-wide analytics across all departments",
                  ),
                  _ReportMenuCard(
                    title: "Overall Report",
                    subtitle:
                        "$totalComplaints total complaints · $totalDepts departments",
                    icon: Icons.bar_chart,
                    iconBg: const Color(0xFFFFA726),
                    trailing: const _GoChip(label: "View"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminOverallReportScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── DEPARTMENT REPORTS ────────────────────────
                  SectionHeader(
                    title: "Department Reports",
                    subtitle:
                        "$totalDepts department${totalDepts != 1 ? 's' : ''}",
                  ),

                  if (departments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          "No departments found",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ...departments.map((dept) {
                      final count =
                          deptComplaintCounts[dept.id] ?? 0;

                      return _ReportMenuCard(
                        title: dept.name,
                        subtitle:
                            "$count complaint${count != 1 ? 's' : ''}",
                        icon: Icons.apartment,
                        iconBg: kPrimaryBlue,
                        trailing: count > 0
                            ? _CountBadge(count: count)
                            : const _EmptyBadge(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DepartmentReportScreen(
                                departmentId: dept.id,
                                departmentName: dept.name,
                              ),
                            ),
                          );
                        },
                      );
                    }),

                  const SizedBox(height: 16),
                ],
              ),
            ),

      bottomNavigationBar: adminBottomNav(context, _currentIndex),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REPORT MENU CARD
// ─────────────────────────────────────────────────────────────
class _ReportMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Widget trailing;
  final VoidCallback onTap;

  const _ReportMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconBg, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
            trailing,
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TRAILING WIDGETS
// ─────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _EmptyBadge extends StatelessWidget {
  const _EmptyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "No data",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GoChip extends StatelessWidget {
  final String label;
  const _GoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFFFA726),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}