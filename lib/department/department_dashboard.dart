import 'package:flutter/material.dart';
import 'department_navigation.dart';
import 'department_routes.dart';
import '../services/departmentComplaintService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/complaint.dart';
import '../services/department_service.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';

class DepartmentDashboard extends StatefulWidget {
  const DepartmentDashboard({super.key});

  @override
  State<DepartmentDashboard> createState() => _DepartmentDashboardState();
}

class _DepartmentDashboardState extends State<DepartmentDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;

  String departmentName = "Loading...";
  List<Complaint> complaints = [];

  int newCount = 0;
  int activeCount = 0;
  int progressCount = 0;
  int resolvedCount = 0;

  bool isLoading = true;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboardData();
    });
  }

  Future<void> loadDashboardData() async {
    try {
      final departmentId =
          context.read<DepartmentProvider>().departmentId;

      if (departmentId == null) return;

      departmentName =
          await DepartmentService().getDepartmentName(departmentId);

      complaints = await DepartmentComplaintService()
          .getAssignedComplaints(departmentId);

      setState(() {
        newCount =
            complaints.where((c) => c.status == "Approved").length;
        progressCount =
            complaints.where((c) => c.status == "InProgress").length;
        resolvedCount =
            complaints.where((c) => c.status == "Resolved").length;

        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DepartmentProvider>();

    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          departmentName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),

      /// ---------------- Body ----------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---- Section: Overview ----
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: "Assigned", // rename this too
                          count: newCount.toString(),
                          color: const Color(0xFFFFA726),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: DashboardCard(
                          title: "In Progress",
                          count: progressCount.toString(),
                          color: const Color(0xFF43A047),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: DashboardCard(
                          title: "Resolved",
                          count: resolvedCount.toString(),
                          color: const Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// ---- Section: Manage Users (officers only) ----
                  if (provider.isOfficer) ...[
                    const Text(
                      "Administration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.group_add,
                              color: primaryBlue, size: 26),
                        ),
                        title: const Text(
                          "Manage Department Users",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        subtitle: const Text(
                          "Create and manage users in your department",
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: primaryBlue),
                        onTap: () {
                          Navigator.pushNamed(
                              context, DepartmentRoutes.manageUsers);
                        },
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],

                  /// ---- Section: Recent Complaints ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Complaints",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, DepartmentRoutes.list);
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...complaints.take(3).map((c) {
                    return ComplaintCard(
                      title: c.categoryName,
                      location: c.location,
                      date: c.createdAt?.toString().split(" ")[0] ?? "",
                      status: c.status,
                      priority: c.priority,
                      priorityColor:
                          c.priority == "High" ? Colors.red : Colors.amber,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          DepartmentRoutes.complaintDetail,
                          arguments: {
                            'complaintId': c.complaintId,
                            'source': 'dashboard',
                          },
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

      /// ---------------- Bottom Nav ----------------
      bottomNavigationBar: departmentBottomNav(context, _currentIndex),
    );
  }
}

/// ---------------- Dashboard Card ----------------
class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- Complaint Card ----------------
class ComplaintCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String status;
  final String priority;
  final Color priorityColor;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.priority,
    required this.priorityColor,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "InProgress":
        return Colors.blue;
      case "Resolved":
        return Colors.teal;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -------- TITLE + STATUS --------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// -------- LOCATION --------
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// -------- DATE --------
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              /// -------- PRIORITY BADGE --------
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priority,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}