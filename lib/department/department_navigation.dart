import 'package:flutter/material.dart';
import 'department_routes.dart';

const Color primaryBlue = Color(0xFF0A1F44);
const Color lightGrey = Color(0xFFF4F6F8);

/// ---------------- Drawer ----------------
Drawer departmentDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: primaryBlue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Department Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Sanitation Department",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        drawerItem(
          context,
          Icons.dashboard,
          "Dashboard",
          DepartmentRoutes.dashboard,
        ),
        drawerItem(
          context,
          Icons.report,
          "Complaints",
          DepartmentRoutes.list,
        ),
        drawerItem(
          context,
          Icons.bar_chart,
          "Reports",
          DepartmentRoutes.reports,
        ),
        drawerItem(
          context,
          Icons.settings,
          "Settings",
          DepartmentRoutes.settings,
        ),

        const Divider(),

        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout, color: Colors.red),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
          ),
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    ),
  );
}

ListTile drawerItem(
  BuildContext context,
  IconData icon,
  String title,
  String route,
) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: primaryBlue),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, route);
    },
  );
}

/// ---------------- Bottom Navigation ----------------
BottomNavigationBar departmentBottomNav(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, DepartmentRoutes.dashboard);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, DepartmentRoutes.list);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, DepartmentRoutes.reports);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, DepartmentRoutes.settings);
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: Icon(Icons.report), label: "Complaints"),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
    ],
  );
}

/// ---------------- Logout Dialog ----------------
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 12),
          Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Add logout logic here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out successfully")),
            );
          },
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}