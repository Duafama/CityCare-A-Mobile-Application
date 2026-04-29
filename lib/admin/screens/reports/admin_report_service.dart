import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/complaint.dart';
import '../../../models/department.dart';

class AdminReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── All complaints ──────────────────────────────────────────
  // Future<List<Complaint>> getAllComplaints() async {
  //   final snapshot = await _firestore.collection('complaints').get();
  //   return snapshot.docs
  //       .map((doc) => Complaint.fromMap(doc.id, doc.data()))
  //       .toList();
  // }

  // ── All departments ─────────────────────────────────────────
  Future<List<Department>> getAllDepartments() async {
    final snapshot = await _firestore.collection('departments').get();
    return snapshot.docs
        .map((doc) => Department.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── Complaints for one department ───────────────────────────
  Future<List<Complaint>> getComplaintsForDepartment(
      String departmentId) async {
    final snapshot = await _firestore
        .collection('complaints')
        .where('departmentId', isEqualTo: departmentId)
        .get();
    return snapshot.docs
        .map((doc) => Complaint.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── Period filter helper ────────────────────────────────────
  static List<Complaint> filterByPeriod(
      List<Complaint> complaints, String period) {
    final now = DateTime.now();
    return complaints.where((c) {
      if (c.createdAt == null) return false;
      final date = c.createdAt!;
      switch (period) {
        case "Today":
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case "This Week":
          final weekStart =
              now.subtract(Duration(days: now.weekday - 1));
          return date.isAfter(DateTime(
                  weekStart.year, weekStart.month, weekStart.day)
              .subtract(const Duration(seconds: 1)));
        case "This Month":
          return date.year == now.year && date.month == now.month;
        case "This Year":
          return date.year == now.year;
        default: // All Time
          return true;
      }
    }).toList();
  }

  // ── Status counts ───────────────────────────────────────────
  static Map<String, int> statusCounts(List<Complaint> complaints) {
    final Map<String, int> counts = {
      "Pending": 0,
      "Approved": 0,
      "InProgress": 0,
      "Resolved": 0,
      "Rejected": 0,
    };
    for (final c in complaints) {
      if (counts.containsKey(c.status)) {
        counts[c.status] = counts[c.status]! + 1;
      }
    }
    return counts;
  }

  // ── Priority counts ─────────────────────────────────────────
  static Map<String, int> priorityCounts(List<Complaint> complaints) {
    final Map<String, int> counts = {"High": 0, "Medium": 0, "Low": 0};
    for (final c in complaints) {
      if (counts.containsKey(c.priority)) {
        counts[c.priority] = counts[c.priority]! + 1;
      }
    }
    return counts;
  }

  // ── Group by category ───────────────────────────────────────
  static Map<String, List<Complaint>> groupByCategory(
      List<Complaint> complaints) {
    final Map<String, List<Complaint>> map = {};
    for (final c in complaints) {
      map.putIfAbsent(c.categoryName, () => []).add(c);
    }
    return map;
  }

  // ── Resolution rate ─────────────────────────────────────────
  static double resolutionRate(List<Complaint> complaints) {
    if (complaints.isEmpty) return 0;
    final resolved =
        complaints.where((c) => c.status == "Resolved").length;
    return (resolved / complaints.length) * 100;
  }
}