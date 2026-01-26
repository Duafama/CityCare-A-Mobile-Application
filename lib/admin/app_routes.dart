import 'package:flutter/material.dart';

// Dashboard
import 'admin_dashboard.dart';

// Reports
import 'screens/reports/reports_menu.dart';
import 'screens/reports/report_detail.dart';
import 'screens/reports/department_report_screen.dart';

// Complaints
import 'screens/complaints/complaints_menu.dart';
import 'screens/complaints/complaint_list.dart';
import 'screens/complaints/complaint_detail.dart';

// Settings
import 'screens/settings/settings.dart';
import 'screens/settings/edit_profile.dart';

// Management
import 'screens/management/manage_departments.dart';
import 'screens/management/add_department.dart';
import 'screens/management/department_detail.dart';
import 'screens/management/manage_categories.dart';
import 'screens/management/add_category.dart';
import 'screens/management/category_detail.dart';
import 'screens/management/manage_users.dart';
import 'screens/management/user_detail.dart';
import 'screens/management/flagged_comments.dart';
import 'screens/management/comment_detail.dart';

class AppRoutes {
  // Admin Dashboard
  static const adminDashboard = '/adminDashboard';

  // Reports
  static const reportsMenu = '/reportsMenu';
  static const reportDetail = '/reportDetail';
  static const departmentReport = '/departmentReport';

  // Complaints
  static const complaintsMenu = '/complaintsMenu';
  static const complaintList = '/complaintList';
  static const complaintDetail = '/complaintDetail';

  // Settings
  static const settings = '/settings';
  static const editProfile = '/editProfile';

  // Departments
  static const manageDepartments = '/manageDepartments';
  static const addDepartment = '/addDepartment';
  static const departmentDetail = '/departmentDetail';

  // Categories
  static const manageCategories = '/manageCategories';
  static const addCategory = '/addCategory';
  static const categoryDetail = '/categoryDetail';

  // Users
  static const manageUsers = '/manageUsers';
  static const userDetail = '/userDetail';

  // Comments
  static const flaggedComments = '/flaggedComments';
  static const commentDetail = '/commentDetail';

  /// Admin routes map
  static final Map<String, WidgetBuilder> routes = {
    adminDashboard: (_) => const AdminDashboard(),

    // Reports
    reportsMenu: (_) => const ReportsMenuScreen(),
    reportDetail: (_) => const ReportDetailScreen(),
    departmentReport: (_) => DepartmentReportScreen(department: "Sanitation"),

    // Complaints
    complaintsMenu: (_) => const ComplaintsMenuScreen(),
    complaintList: (_) => const ComplaintListScreen(),
    complaintDetail: (_) => const ComplaintDetailScreen(),

    // Settings
    settings: (_) => const SettingsScreen(),
    editProfile: (_) => const EditProfileScreen(),

    // Departments
    manageDepartments: (_) => const ManageDepartmentsScreen(),
    addDepartment: (_) => const AddDepartmentScreen(),
    departmentDetail: (_) => DepartmentDetailScreen(name: "Maintenance"),

    // Categories
    manageCategories: (_) => const ManageCategoriesScreen(),
    addCategory: (_) => const AddCategoryScreen(),
    categoryDetail: (_) =>
        CategoryDetailScreen(name: "Electronics", department: "IT"),

    // Users
    manageUsers: (_) => const ManageUsersScreen(),
    userDetail: (_) => UserDetailScreen(userName: "John Doe"),

    // Comments
    flaggedComments: (_) => const FlaggedCommentsScreen(),
    commentDetail: (_) => CommentDetailScreen(
      comment: "Sample Comment",
      user: "Jane Doe",
      post: "Example Post",
      createdAt: "2026-01-25 10:00",
    ),
  };
}
