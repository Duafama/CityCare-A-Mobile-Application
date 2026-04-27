// lib/models/complaint_enums.dart

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

  // 🔥 Get all statuses for filter (including "All" option)
  static List<ComplaintStatus?> getFilterOptions() {
    return [null, ...ComplaintStatus.values]; // null means "All"
  }
  
  // 🔥 Get display name for filter
  static String getFilterDisplayName(ComplaintStatus? status) {
    if (status == null) return 'All';
    return status.value;
  }
}