import 'package:flutter/material.dart';
import 'app_routes.dart';

const Color primaryBlue = Color(0xFF0A1F44);
const Color lightGrey = Color(0xFFF4F6F8);

/// ---------------- Drawer ----------------
Drawer adminDrawer(BuildContext context) {
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
                "Admin Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "admin@citycare.com",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        drawerItem(
          context,
          Icons.apartment,
          "Manage Departments",
          AppRoutes.manageDepartments,
        ),
        drawerItem(
          context,
          Icons.category,
          "Manage Categories",
          AppRoutes.manageCategories,
        ),
        drawerItem(
          context,
          Icons.people,
          "Manage Users",
          AppRoutes.manageUsers,
        ),
        drawerItem(
          context,
          Icons.flag,
          "Flagged Comments",
          AppRoutes.flaggedComments,
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
      Navigator.pushNamed(context, route);
    },
  );
}

/// ---------------- Bottom Navigation ----------------
BottomNavigationBar adminBottomNav(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, AppRoutes.complaintsMenu);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRoutes.reportsMenu);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, AppRoutes.settings);
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
