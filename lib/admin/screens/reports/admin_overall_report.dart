import 'package:flutter/material.dart';
import '../../../models/complaint.dart';
import '../../../models/department.dart';
import 'admin_report_service.dart';
import 'report_widgets.dart';
import 'department_report_screen.dart';

class AdminOverallReportScreen extends StatefulWidget {
  const AdminOverallReportScreen({super.key});

  @override
  State<AdminOverallReportScreen> createState() =>
      _AdminOverallReportScreenState();
}

class _AdminOverallReportScreenState
    extends State<AdminOverallReportScreen> {
  String selectedPeriod = "All Time";

  List<Complaint> allComplaints = [];
  List<Department> departments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final service = AdminReportService();
      final complaints = await service.getAllComplaints();
      final depts = await service.getAllDepartments();

      setState(() {
        allComplaints = complaints;
        departments = depts;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  List<Complaint> get _filtered =>
      AdminReportService.filterByPeriod(allComplaints, selectedPeriod);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final total = filtered.length;
    final statusCounts = AdminReportService.statusCounts(filtered);
    final priorityCounts = AdminReportService.priorityCounts(filtered);
    final resRate = AdminReportService.resolutionRate(filtered);

    return Scaffold(
      backgroundColor: kLightGrey,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Overall Report",
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryBlue,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PeriodFilterBar(
                  selected: selectedPeriod,
                  onSelected: (p) => setState(() => selectedPeriod = p),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── TOP SUMMARY ROW ──────────────────────────
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
                              value: total.toString(),
                              icon: Icons.bar_chart,
                              color: kPrimaryBlue,
                            ),
                            ReportStatCard(
                              label: "Resolution Rate",
                              value:
                                  "${resRate.toStringAsFixed(0)}%",
                              icon: Icons.trending_up,
                              color: const Color(0xFF00897B),
                            ),
                            ReportStatCard(
                              label: "Resolved",
                              value: statusCounts["Resolved"]
                                  .toString(),
                              icon: Icons.check_circle_outline,
                              color: const Color(0xFF43A047),
                            ),
                            ReportStatCard(
                              label: "Pending",
                              value: statusCounts["Pending"]
                                  .toString(),
                              icon: Icons.hourglass_empty,
                              color: const Color(0xFFFFA726),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── STATUS BAR CHART ─────────────────────────
                        if (total > 0) ...[
                          StatusBarChart(
                            statusCounts: statusCounts,
                            total: total,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── PRIORITY ─────────────────────────────────
                        PriorityProgressSection(
                          priorityCounts: priorityCounts,
                          total: total,
                        ),

                        const SizedBox(height: 24),

                        // ── DEPARTMENT BREAKDOWN ─────────────────────
                        const SectionHeader(
                          title: "Department Breakdown",
                          subtitle:
                              "Tap a department to view its full report",
                        ),

                        ...departments.map((dept) {
                          final deptComplaints = filtered
                              .where(
                                  (c) => c.departmentId == dept.id)
                              .toList();
                          final deptTotal = deptComplaints.length;
                          final deptResolved = deptComplaints
                              .where(
                                  (c) => c.status == "Resolved")
                              .length;
                          final deptRate = deptTotal > 0
                              ? ((deptResolved / deptTotal) * 100)
                                  .toStringAsFixed(0)
                              : "0";

                          return _DepartmentBreakdownTile(
                            department: dept,
                            total: deptTotal,
                            resolved: deptResolved,
                            resRate: deptRate,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DepartmentReportScreen(
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
                ),
              ],
            ),
    );
  }
}

/// ── Department breakdown tile ─────────────────────────────────
class _DepartmentBreakdownTile extends StatelessWidget {
  final Department department;
  final int total;
  final int resolved;
  final String resRate;
  final VoidCallback onTap;

  const _DepartmentBreakdownTile({
    required this.department,
    required this.total,
    required this.resolved,
    required this.resRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? resolved / total : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: kPrimaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment,
                      color: kPrimaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "$total complaint${total != 1 ? 's' : ''} · $resRate% resolved",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kPrimaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    total.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: Colors.grey, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade100,
                color: const Color(0xFF00897B),
                minHeight: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}