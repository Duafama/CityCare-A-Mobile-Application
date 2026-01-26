import 'package:flutter/material.dart';
import 'admin_navigation.dart';
import '/screens/welcome_screen.dart'; // import your WelcomeScreen

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final int _currentIndex = 0;

  static const Color primaryBlue = Color(0xFF0A1F44); // navy blue
  static const Color lightGrey = Color(0xFFF4F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // sidebar (hamburger) button color
        ),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,

        /// ← Add action button here
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Back to Welcome',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            },
          ),
        ],
      ),

      /// ---------------- Drawer ----------------
      drawer: adminDrawer(context),

      /// ---------------- Body ----------------
      body: SingleChildScrollView(
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

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DashboardCard(
                  title: "Pending",
                  count: "12",
                  color: Color(0xFFFFA726),
                ),
                DashboardCard(
                  title: "Approved",
                  count: "30",
                  color: Color(0xFF43A047),
                ),
                DashboardCard(
                  title: "In Progress",
                  count: "18",
                  color: Color(0xFF1E88E5),
                ),
                DashboardCard(
                  title: "Resolved",
                  count: "45",
                  color: Color(0xFF00897B),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// ---- Section: Departments ----
            const Text(
              "Department Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            departmentTile("Sanitation", 15),
            departmentTile("Roads", 22),
            departmentTile("Water Supply", 18),
            departmentTile("Electricity", 10),
          ],
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.apartment, color: primaryBlue),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
