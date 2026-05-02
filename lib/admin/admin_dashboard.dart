import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_navigation.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final int _currentIndex = 0;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),

      /// ---------------- Drawer ----------------
      drawer: adminDrawer(context),

      /// ---------------- Body ----------------
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading data",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          /// 🔥 STATUS COUNTS
          int pending = 0;
          int approved = 0;
          int inProgress = 0;
          int resolved = 0;

          /// 🔥 DEPARTMENT COUNTS - Only for approved, in-progress, and resolved complaints
          Map<String, int> deptCounts = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final status = data['status'] ?? '';
            String dept = data['departmentName'] ?? '';

            // Clean up department name
            if (dept.trim().isEmpty || dept == "null" || dept == "Unknown") {
              dept = "Not Assigned";
            }

            /// Count status (case-insensitive for safety)
            final statusLower = status.toLowerCase();
            if (statusLower == "pending")
              pending++;
            else if (statusLower == "approved")
              approved++;
            else if (statusLower == "inprogress" ||
                statusLower == "in progress")
              inProgress++;
            else if (statusLower == "resolved") resolved++;

            /// Count departments ONLY for complaints that are NOT pending and NOT rejected
            /// This includes: Approved, InProgress, Resolved
            final shouldCountDepartment = statusLower != "pending" &&
                statusLower != "rejected" &&
                dept.isNotEmpty;

            if (shouldCountDepartment) {
              deptCounts[dept] = (deptCounts[dept] ?? 0) + 1;
            }
          }

          // Sort departments alphabetically
          final sortedDepts = deptCounts.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---- Overview Section ----
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.dashboard,
                            color: primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DashboardCard(
                        title: "Pending",
                        count: pending.toString(),
                        color: const Color(0xFFFFA726),
                        icon: Icons.pending_actions,
                      ),
                      DashboardCard(
                        title: "Approved",
                        count: approved.toString(),
                        color: const Color(0xFF43A047),
                        icon: Icons.check_circle,
                      ),
                      DashboardCard(
                        title: "In Progress",
                        count: inProgress.toString(),
                        color: const Color(0xFF1E88E5),
                        icon: Icons.engineering,
                      ),
                      DashboardCard(
                        title: "Resolved",
                        count: resolved.toString(),
                        color: const Color(0xFF00897B),
                        icon: Icons.done_all,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// ---- Departments Section ----
                  Row(
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
                      const Expanded(
                        child: Text(
                          "Department Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.business_center,
                              size: 14,
                              color: primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${sortedDepts.length} depts",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// Info note about department counting
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Showing department assignments for Approved, In Progress, and Resolved complaints only. Pending and Rejected complaints are not assigned to departments.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (sortedDepts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No department assignments yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Departments appear when complaints are approved",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedDepts.length,
                      itemBuilder: (context, index) {
                        final entry = sortedDepts[index];
                        return departmentTile(entry.key, entry.value);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),

      /// ---------------- Bottom Nav ----------------
      bottomNavigationBar: adminBottomNav(context, _currentIndex),
    );
  }

  /// ---------------- Department Tile ----------------
  Widget departmentTile(String name, int count) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            name == "Not Assigned" ? Icons.help_outline : Icons.apartment,
            color: primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Container(
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue,
                primaryBlue.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// ---------------- Dashboard Card ----------------
class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
