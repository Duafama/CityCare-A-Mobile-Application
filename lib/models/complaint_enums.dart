import 'package:flutter/material.dart';

enum ComplaintStatus {
  pending,
  approved,
  inProgress,
  resolved,
  rejected,
}

// Extension for converting enum to string and vice versa
extension ComplaintStatusExtension on ComplaintStatus {
  String get value {
    switch (this) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.approved:
        return 'Approved';
      case ComplaintStatus.inProgress:
        return 'InProgress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.rejected:
        return 'Rejected';
    }
  }

  static ComplaintStatus fromString(String status) {
    switch (status) {
      case 'Pending':
        return ComplaintStatus.pending;
      case 'Approved':
        return ComplaintStatus.approved;
      case 'InProgress':
        return ComplaintStatus.inProgress;
      case 'Resolved':
        return ComplaintStatus.resolved;
      case 'Rejected':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.pending;
    }
  }

  // Get all statuses for filter (including "All" option)
  static List<ComplaintStatus?> getFilterOptions() {
    return [null, ...ComplaintStatus.values];
  }

  // Get display name for filter
  static String getFilterDisplayName(ComplaintStatus? status) {
    if (status == null) return 'All';
    return status.value;
  }

  // Get color for status
  Color getColor() {
    switch (this) {
      case ComplaintStatus.pending:
        return Colors.orange;
      case ComplaintStatus.approved:
        return Colors.green;
      case ComplaintStatus.inProgress:
        return Colors.blue;
      case ComplaintStatus.resolved:
        return Colors.teal;
      case ComplaintStatus.rejected:
        return Colors.red;
    }
  }

  // Get background color (light version)
  Color getBackgroundColor() {
    return getColor().withOpacity(0.1);
  }

  // Get icon for status
  IconData getIcon() {
    switch (this) {
      case ComplaintStatus.pending:
        return Icons.hourglass_empty;
      case ComplaintStatus.approved:
        return Icons.check_circle;
      case ComplaintStatus.inProgress:
        return Icons.autorenew;
      case ComplaintStatus.resolved:
        return Icons.done_all;
      case ComplaintStatus.rejected:
        return Icons.cancel;
    }
  }
}
