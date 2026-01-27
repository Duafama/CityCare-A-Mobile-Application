import 'package:flutter/material.dart';

import 'department_dashboard.dart';
import 'department_complaint_list.dart';
import 'department_complaint_detail.dart';
import 'update_status_screen.dart';
import 'upload_resolution_screen.dart';
import 'department_reports.dart';
import 'department_settings.dart';

class DepartmentRoutes {
  static const dashboard = '/deptDashboard';
  static const list = '/deptComplaints';
  static const complaintDetail = '/deptComplaintDetail';
  static const updateStatus = '/deptUpdateStatus';
  static const uploadProof = '/deptUploadProof';
  static const reports = '/deptReports';
  static const settings = '/deptSettings';

  static final routes = {
    dashboard: (_) => const DepartmentDashboard(),
    list: (_) => const DepartmentComplaintList(),
    complaintDetail: (_) => const DepartmentComplaintDetail(),
    updateStatus: (_) => const UpdateStatusScreen(),
    uploadProof: (_) => const UploadResolutionScreen(),
    reports: (_) => const DepartmentReportsScreen(),
    settings: (_) => const DepartmentSettingsScreen(),
  };
}