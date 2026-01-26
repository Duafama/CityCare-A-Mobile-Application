import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../admin_navigation.dart';

class ComplaintsMenuScreen extends StatefulWidget {
  const ComplaintsMenuScreen({super.key});

  @override
  State<ComplaintsMenuScreen> createState() => _ComplaintsMenuScreenState();
}

class _ComplaintsMenuScreenState extends State<ComplaintsMenuScreen> {
  final int _currentIndex = 1; // Complaints tab

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final List<Map<String, dynamic>> statuses = [
    {"title": "Pending", "icon": Icons.hourglass_empty, "color": Colors.orange},
    {"title": "Approved", "icon": Icons.check_circle, "color": Colors.green},
    {"title": "In Progress", "icon": Icons.autorenew, "color": Colors.blue},
    {"title": "Resolved", "icon": Icons.done_all, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 350 ? 1 : 2;
    final childAspectRatio = screenWidth < 350 ? 2.5 : 1.2;

    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Complaints",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),

      /// ---------------- Drawer ----------------
      drawer: adminDrawer(context),

      /// ---------------- Body ----------------
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Complaint Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 16),

              /// Use Expanded GridView to fill remaining space safely
              Expanded(
                child: GridView.builder(
                  itemCount: statuses.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final status = statuses[index];
                    return complaintCard(
                      context,
                      status["title"],
                      status["icon"],
                      status["color"],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      /// ---------------- Bottom Navigation ----------------
      bottomNavigationBar: adminBottomNav(context, _currentIndex),
    );
  }

  /// ---------------- Complaint Card ----------------
  Widget complaintCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.complaintList, arguments: title);
      },
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
