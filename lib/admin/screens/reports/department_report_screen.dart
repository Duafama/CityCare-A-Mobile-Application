import 'package:flutter/material.dart';
import '../../../models/complaint.dart';
import 'admin_report_service.dart';
import 'report_widgets.dart';

class DepartmentReportScreen extends StatefulWidget {
  final String departmentId;
  final String departmentName;

  const DepartmentReportScreen({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  State<DepartmentReportScreen> createState() =>
      _DepartmentReportScreenState();
}

class _DepartmentReportScreenState extends State<DepartmentReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String selectedPeriod = "All Time";

  List<Complaint> allComplaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final complaints = await AdminReportService()
          .getComplaintsForDepartment(widget.departmentId);
      setState(() {
        allComplaints = complaints;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  List<Complaint> get _filtered =>
      AdminReportService.filterByPeriod(allComplaints, selectedPeriod);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.departmentName,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "By Category"),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PeriodFilterBar(
                  selected: selectedPeriod,
                  onSelected: (p) => setState(() => selectedPeriod = p),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(filtered: _filtered),
                      _CategoryTab(filtered: _filtered),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 1 — OVERVIEW
// ═══════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final List<Complaint> filtered;

  const _OverviewTab({required this.filtered});

  @override
  Widget build(BuildContext context) {
    final total = filtered.length;
    final statusCounts = AdminReportService.statusCounts(filtered);
    final priorityCounts = AdminReportService.priorityCounts(filtered);
    final resRate = AdminReportService.resolutionRate(filtered);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP STAT CARDS ──────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ReportStatCard(
                label: "Total",
                value: total.toString(),
                icon: Icons.bar_chart,
                color: kPrimaryBlue,
              ),
              ReportStatCard(
                label: "Resolution Rate",
                value: "${resRate.toStringAsFixed(0)}%",
                icon: Icons.trending_up,
                color: const Color(0xFF00897B),
              ),
              ReportStatCard(
                label: "Resolved",
                value: statusCounts["Resolved"].toString(),
                icon: Icons.check_circle_outline,
                color: const Color(0xFF43A047),
              ),
              ReportStatCard(
                label: "In Progress",
                value: statusCounts["InProgress"].toString(),
                icon: Icons.autorenew,
                color: const Color(0xFF1E88E5),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── STATUS CHART ────────────────────────────────────
          StatusBarChart(statusCounts: statusCounts, total: total),

          const SizedBox(height: 24),

          // ── PRIORITY ────────────────────────────────────────
          PriorityProgressSection(
            priorityCounts: priorityCounts,
            total: total,
          ),

          // ── RECENT LIST ─────────────────────────────────────
          if (filtered.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(
              title: "Recent Complaints",
              subtitle: "Latest 5 in selected period",
            ),
            ...filtered
                .take(5)
                .map((c) => _RecentComplaintTile(complaint: c)),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2 — BY CATEGORY
// ═══════════════════════════════════════════════════════════════
class _CategoryTab extends StatelessWidget {
  final List<Complaint> filtered;

  const _CategoryTab({required this.filtered});

  @override
  Widget build(BuildContext context) {
    final byCategory = AdminReportService.groupByCategory(filtered);

    if (byCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined,
                size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No data for selected period",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final totalFiltered = filtered.length;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SectionHeader(
              title:
                  "${sorted.length} Categor${sorted.length != 1 ? 'ies' : 'y'}",
              subtitle: "Across $totalFiltered total complaints",
            ),
          );
        }

        final entry = sorted[index - 1];
        final color = kCategoryPalette[(index - 1) % kCategoryPalette.length];
        return _CategoryExpandableCard(
          categoryName: entry.key,
          complaints: entry.value,
          total: totalFiltered,
          color: color,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EXPANDABLE CATEGORY CARD
// ─────────────────────────────────────────────────────────────
class _CategoryExpandableCard extends StatefulWidget {
  final String categoryName;
  final List<Complaint> complaints;
  final int total; // overall total for percentage share
  final Color color;

  const _CategoryExpandableCard({
    required this.categoryName,
    required this.complaints,
    required this.total,
    required this.color,
  });

  @override
  State<_CategoryExpandableCard> createState() =>
      _CategoryExpandableCardState();
}

class _CategoryExpandableCardState extends State<_CategoryExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final catTotal = widget.complaints.length;
    final shareOfTotal = widget.total > 0 ? catTotal / widget.total : 0.0;

    final catStatus = AdminReportService.statusCounts(widget.complaints);
    final resolved = catStatus["Resolved"]!;
    final resRate = catTotal > 0
        ? ((resolved / catTotal) * 100).toStringAsFixed(0)
        : "0";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── HEADER ─────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.category,
                            color: widget.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$catTotal complaints · $resRate% resolved · ${(shareOfTotal * 100).toStringAsFixed(0)}% of total",
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          catTotal.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Share-of-total progress
                  Row(
                    children: [
                      const Text(
                        "Share:",
                        style: TextStyle(
                            fontSize: 11, color: Colors.black38),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: shareOfTotal,
                            backgroundColor: Colors.grey.shade100,
                            color: widget.color,
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${(shareOfTotal * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── EXPANDED DETAIL ─────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Breakdown",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: kPrimaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...catStatus.entries.map((e) {
                    final pct =
                        catTotal > 0 ? e.value / catTotal : 0.0;
                    final statusColor =
                        kStatusColors[e.key] ?? Colors.grey;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Text(
                                "${e.value} (${(pct * 100).toStringAsFixed(0)}%)",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.grey.shade100,
                              color: statusColor,
                              minHeight: 7,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RECENT COMPLAINT TILE
// ─────────────────────────────────────────────────────────────
class _RecentComplaintTile extends StatelessWidget {
  final complaint;

  const _RecentComplaintTile({required this.complaint});

  Color _statusColor(String status) {
    return kStatusColors[status] ?? Colors.grey;
  }

  Color _priorityColor(String priority) {
    return kPriorityColors[priority] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  complaint.location,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black45),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(complaint.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  complaint.status,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor(complaint.priority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  complaint.priority,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}