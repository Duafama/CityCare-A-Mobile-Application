import 'package:flutter/material.dart';

// Dashboard
import 'admin_dashboard.dart';

// Reports
import 'screens/reports/reports_menu.dart';
import 'screens/reports/admin_overall_report.dart';
import 'screens/reports/department_report_screen.dart';

// Complaints
import 'screens/complaints/complaints_menu.dart';
import 'screens/complaints/complaint_list.dart';
import 'screens/complaints/complaint_detail.dart';

import 'profile_screen.dart';

// Management
import 'screens/management/manage_departments.dart';
import 'screens/management/add_department.dart';
import 'screens/management/manage_categories.dart';
import 'screens/management/add_category.dart';
import 'screens/management/category_detail.dart';
import 'screens/management/manage_users.dart';
import 'screens/management/user_detail.dart';
import 'screens/management/flagged_comments.dart';
import 'screens/management/comment_detail.dart';

class AppRoutes {
  static const adminDashboard = '/adminDashboard';

  static const reportsMenu = '/reportsMenu';
  static const overallReport = '/overallReport';
  static const departmentReport = '/departmentReport';

  static const complaintsMenu = '/complaintsMenu';
  static const complaintList = '/complaintList';
  static const complaintDetail = '/complaintDetail';

  static const manageDepartments = '/manageDepartments';
  static const addDepartment = '/addDepartment';

  static const profile = '/profile';

  static const manageCategories = '/manageCategories';
  static const addCategory = '/addCategory';
  static const categoryDetail = '/categoryDetail';

  static const manageUsers = '/manageUsers';
  static const userDetail = '/userDetail';

  static const flaggedComments = '/flaggedComments';
  static const commentDetail = '/commentDetail';

  /// ---------------- ROUTES MAP ----------------
  static final Map<String, WidgetBuilder> routes = {
    adminDashboard: (_) => const AdminDashboard(),

    reportsMenu: (_) => const ReportsMenuScreen(),

    overallReport: (_) => const AdminOverallReportScreen(),

    /// DepartmentReportScreen now requires departmentId + departmentName.
    /// These are always passed via Navigator.push() with MaterialPageRoute
    /// directly from ReportsMenuScreen and AdminOverallReportScreen,
    /// so this named route entry is just a safe fallback.
    departmentReport: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, String>) {
        return DepartmentReportScreen(
          departmentId: args['departmentId'] ?? '',
          departmentName: args['departmentName'] ?? 'Department',
        );
      }
      // Fallback — should not normally be reached
      return const Scaffold(
        body: Center(child: Text("No department selected.")),
      );
    },

    complaintsMenu: (_) => const ComplaintsMenuScreen(),
    complaintList: (_) => const ComplaintListScreen(),
    complaintDetail: (_) => const ComplaintDetailScreen(),

    profile: (_) => const ProfileScreen(),

    manageDepartments: (_) => const ManageDepartmentsScreen(),
    addDepartment: (_) => const AddDepartmentScreen(),

    manageCategories: (_) => const ManageCategoriesScreen(),
    addCategory: (_) => const AddCategoryScreen(),

    manageUsers: (_) => const ManageUsersScreen(),

    flaggedComments: (_) => const FlaggedCommentsScreen(),
    commentDetail: (_) => const CommentDetailScreen(
          comment: "Sample Comment",
          user: "Jane Doe",
          post: "Example Post",
          createdAt: "2026-01-25 10:00",
        ),
  };
}