// lib/models/priority_enums.dart
import 'package:flutter/material.dart';
enum ComplaintPriority {
  low,
  medium,
  high,
}

// Extension for converting enum to string and vice versa
extension ComplaintPriorityExtension on ComplaintPriority {
  String get value {
    switch (this) {
      case ComplaintPriority.low:
        return 'Low';
      case ComplaintPriority.medium:
        return 'Medium';
      case ComplaintPriority.high:
        return 'High';
    }
  }

  static ComplaintPriority fromString(String priority) {
    switch (priority) {
      case 'Low':
        return ComplaintPriority.low;
      case 'Medium':
        return ComplaintPriority.medium;
      case 'High':
        return ComplaintPriority.high;
      default:
        return ComplaintPriority.medium;
    }
  }

  // 🔥 Get all priorities for filter (including "All" option)
  static List<ComplaintPriority?> getFilterOptions() {
    return [null, ...ComplaintPriority.values]; // null means "All"
  }
  
  // 🔥 Get display name for filter
  static String getFilterDisplayName(ComplaintPriority? priority) {
    if (priority == null) return 'All';
    return priority.value;
  }
  
  // 🔥 Get color for priority
  Color getColor() {
    switch (this) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
    }
  }
  
  // 🔥 Get background color (light version)
  Color getBackgroundColor() {
    switch (this) {
      case ComplaintPriority.low:
        return Colors.green.withOpacity(0.1);
      case ComplaintPriority.medium:
        return Colors.orange.withOpacity(0.1);
      case ComplaintPriority.high:
        return Colors.red.withOpacity(0.1);
    }
  }
  
  // 🔥 Get icon for priority
  IconData getIcon() {
    switch (this) {
      case ComplaintPriority.low:
        return Icons.arrow_downward;
      case ComplaintPriority.medium:
        return Icons.remove;
      case ComplaintPriority.high:
        return Icons.arrow_upward;
    }
  }
}