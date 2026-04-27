import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../../models/complaint_enums.dart';
import '../../admin_navigation.dart'; // 👈 import your nav file

class ComplaintsMenuScreen extends StatefulWidget {
  const ComplaintsMenuScreen({super.key});

  @override
  State<ComplaintsMenuScreen> createState() => _ComplaintsMenuScreenState();
}

class _ComplaintsMenuScreenState extends State<ComplaintsMenuScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final List<Map<String, dynamic>> statuses = [
    {
      "status": ComplaintStatus.pending,
      "icon": Icons.hourglass_empty,
      "color": Colors.orange,
    },
    {
      "status": ComplaintStatus.approved,
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
    {
      "status": ComplaintStatus.inProgress,
      "icon": Icons.autorenew,
      "color": Colors.blue,
    },
    {
      "status": ComplaintStatus.resolved,
      "icon": Icons.done_all,
      "color": Colors.teal,
    },
    {
      "status": ComplaintStatus.rejected,
      "icon": Icons.cancel,
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 350 ? 1 : 2;

    return Scaffold(
      backgroundColor: lightGrey,

      /// ✅ AppBar WITHOUT back button
      appBar: AppBar(
        title: const Text(
          "Complaints",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: adminDrawer(context),

      /// ✅ Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Complaint Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: statuses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final item = statuses[index];
                  final ComplaintStatus status = item["status"];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.complaintList,
                        arguments: status,
                      );
                    },
                    child: Container(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item["icon"],
                            color: item["color"],
                            size: 32,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            status.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ✅ Bottom Navigation (Complaints = index 1)
      bottomNavigationBar: adminBottomNav(context, 1),
    );
  }
}
