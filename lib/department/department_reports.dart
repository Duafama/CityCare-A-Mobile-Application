import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'department_navigation.dart';
import 'department_routes.dart';
import '../services/departmentComplaintService.dart';
import '../services/department_service.dart';
import '../models/complaint.dart';
import '../providers/department_provider.dart';

class DepartmentReportsScreen extends StatefulWidget {
  const DepartmentReportsScreen({super.key});

  @override
  State<DepartmentReportsScreen> createState() =>
      _DepartmentReportsScreenState();
}

class _DepartmentReportsScreenState extends State<DepartmentReportsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final int _currentIndex = 3;

  late TabController _tabController;

  String selectedPeriod = "This Month";
  final List<String> periods = [
    "This Week",
    "This Month",
    "This Quarter",
    "This Year",
  ];

  String departmentName = "";
  List<Complaint> allComplaints = [];
  bool isLoading = true;

  /// Colors for status
  static const Map<String, Color> statusColors = {
    "Pending": Color(0xFFFFA726),
    "Approved": Color(0xFF1E88E5),
    "InProgress": Color(0xFF43A047),
    "Resolved": Color(0xFF00897B),
    "Rejected": Color(0xFFE53935),
  };

  /// Colors cycled per category card
  final List<Color> _catColors = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFF00897B),
    Color(0xFFFFA726),
    Color(0xFF8E24AA),
    Color(0xFFE53935),
    Color(0xFF039BE5),
    Color(0xFF6D4C41),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final departmentId =
          context.read<DepartmentProvider>().departmentId;

      if (departmentId == null) return;

      final name = await DepartmentService().getDepartmentName(departmentId);
      final complaints = await DepartmentComplaintService()
          .getAssignedComplaints(departmentId);

      setState(() {
        departmentName = name;
        allComplaints = complaints;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  // -------------------------------------------------------
  // PERIOD FILTER
  // -------------------------------------------------------
  List<Complaint> get _filtered {
    final now = DateTime.now();
    return allComplaints.where((c) {
      if (c.createdAt == null) return false;
      final date = c.createdAt!;

      switch (selectedPeriod) {
        case "This Week":
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return date.isAfter(
              DateTime(weekStart.year, weekStart.month, weekStart.day)
                  .subtract(const Duration(seconds: 1)));

        case "This Month":
          return date.year == now.year && date.month == now.month;

        case "This Quarter":
          final currentQuarterStart =
              DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
          return date.isAfter(
              currentQuarterStart.subtract(const Duration(seconds: 1)));

        case "This Year":
          return date.year == now.year;

        default:
          return true;
      }
    }).toList();
  }

  // -------------------------------------------------------
  // DERIVED STATS — DEPARTMENT WIDE
  // -------------------------------------------------------
  Map<String, int> get _statusCounts {
    final complaints = _filtered;
    final Map<String, int> counts = {
      "Pending": 0,
      "Approved": 0,
      "InProgress": 0,
      "Resolved": 0,
    };
    for (final c in complaints) {
      if (counts.containsKey(c.status)) {
        counts[c.status] = counts[c.status]! + 1;
      }
    }
    return counts;
  }

  Map<String, int> get _priorityCounts {
    final complaints = _filtered;
    final Map<String, int> counts = {
      "Low": 0,
      "Medium": 0,
      "High": 0,
    };
    for (final c in complaints) {
      if (counts.containsKey(c.priority)) {
        counts[c.priority] = counts[c.priority]! + 1;
      }
    }
    return counts;
  }

  double get _resolutionRate {
    final total = _filtered.length;
    if (total == 0) return 0;
    final resolved =
        _filtered.where((c) => c.status == "Resolved").length;
    return (resolved / total) * 100;
  }

  // -------------------------------------------------------
  // DERIVED STATS — CATEGORY WISE
  // -------------------------------------------------------
  Map<String, List<Complaint>> get _byCategory {
    final Map<String, List<Complaint>> map = {};
    for (final c in _filtered) {
      map.putIfAbsent(c.categoryName, () => []).add(c);
    }
    return map;
  }

  // -------------------------------------------------------
  // BUILD
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Reports & Analytics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Department Overview"),
            Tab(text: "By Category"),
          ],
        ),
      ),

      /// ---------------- Body ----------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// -------- PERIOD FILTER (shared) --------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: periods.map((p) {
                        final bool selected = selectedPeriod == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p),
                            selected: selected,
                            selectedColor: primaryBlue,
                            backgroundColor: lightGrey,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedPeriod = p;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DepartmentTab(
                        departmentName: departmentName,
                        filtered: _filtered,
                        statusCounts: _statusCounts,
                        priorityCounts: _priorityCounts,
                        resolutionRate: _resolutionRate,
                        statusColors: statusColors,
                      ),
                      _CategoryTab(
                        byCategory: _byCategory,
                        catColors: _catColors,
                        statusColors: statusColors,
                        onCategoryTap: (categoryName) {
                          Navigator.pushNamed(
                            context,
                            DepartmentRoutes.list,
                            arguments: {'categoryFilter': categoryName},
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

      /// ---------------- Bottom Nav ----------------
      bottomNavigationBar: departmentBottomNav(context, _currentIndex),
    );
  }
}

// =============================================================
// TAB 1 — DEPARTMENT OVERVIEW
// =============================================================
class _DepartmentTab extends StatelessWidget {
  final String departmentName;
  final List<Complaint> filtered;
  final Map<String, int> statusCounts;
  final Map<String, int> priorityCounts;
  final double resolutionRate;
  final Map<String, Color> statusColors;

  static const Color primaryBlue = Color(0xFF0A1F44);

  const _DepartmentTab({
    required this.departmentName,
    required this.filtered,
    required this.statusCounts,
    required this.priorityCounts,
    required this.resolutionRate,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    final total = filtered.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// -------- DEPT NAME + TOTAL --------
          Text(
            departmentName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$total complaint${total != 1 ? 's' : ''} in selected period",
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),

          const SizedBox(height: 20),

          /// -------- SUMMARY STAT CARDS --------
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                label: "Total",
                value: total.toString(),
                icon: Icons.bar_chart,
                color: primaryBlue,
              ),
              _StatCard(
                label: "Resolved",
                value: statusCounts["Resolved"].toString(),
                icon: Icons.check_circle_outline,
                color: const Color(0xFF00897B),
              ),
              _StatCard(
                label: "Resolution Rate",
                value: "${resolutionRate.toStringAsFixed(0)}%",
                icon: Icons.trending_up,
                color: const Color(0xFF43A047),
              ),
              _StatCard(
                label: "Pending",
                value: statusCounts["Pending"].toString(),
                icon: Icons.hourglass_empty,
                color: const Color(0xFFFFA726),
              ),
            ],
          ),

          const SizedBox(height: 28),

          /// -------- STATUS BAR CHART --------
          if (total > 0) ...[
            const Text(
              "Status Distribution",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
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
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => primaryBlue,
                            getTooltipItem: (group, _, rod, __) {
                              final key = statusCounts.keys
                                  .elementAt(group.x.toInt());
                              final val = statusCounts[key]!;
                              final pct = total > 0
                                  ? ((val / total) * 100)
                                      .toStringAsFixed(0)
                                  : "0";
                              return BarTooltipItem(
                                "$key\n$val ($pct%)",
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final labels = [
                                  "Pending",
                                  "Approved",
                                  "In Prog.",
                                  "Resolved",
                                ];
                                final i = value.toInt();
                                if (i < 0 || i >= labels.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    labels[i],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, _) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black38),
                              ),
                            ),
                          ),
                        ),
                        barGroups: [
                          _bar(0, statusCounts["Pending"]!.toDouble(),
                              statusColors["Pending"]!),
                          _bar(1, statusCounts["Approved"]!.toDouble(),
                              statusColors["Approved"]!),
                          _bar(2, statusCounts["InProgress"]!.toDouble(),
                              statusColors["InProgress"]!),
                          _bar(3, statusCounts["Resolved"]!.toDouble(),
                              statusColors["Resolved"]!),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Legend
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: statusCounts.entries.map((e) {
                      final pct = total > 0
                          ? ((e.value / total) * 100)
                              .toStringAsFixed(0)
                          : "0";
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColors[e.key] ?? Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${e.key}: ${e.value} ($pct%)",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],

          /// -------- PRIORITY BREAKDOWN --------
          const Text(
            "Priority Breakdown",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
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
                _PriorityRow(
                  label: "High",
                  count: priorityCounts["High"]!,
                  total: total,
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
                const SizedBox(height: 14),
                _PriorityRow(
                  label: "Medium",
                  count: priorityCounts["Medium"]!,
                  total: total,
                  color: Colors.amber,
                  icon: Icons.remove,
                ),
                const SizedBox(height: 14),
                _PriorityRow(
                  label: "Low",
                  count: priorityCounts["Low"]!,
                  total: total,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

// =============================================================
// TAB 2 — BY CATEGORY
// =============================================================
class _CategoryTab extends StatelessWidget {
  final Map<String, List<Complaint>> byCategory;
  final List<Color> catColors;
  final Map<String, Color> statusColors;
  final void Function(String categoryName) onCategoryTap;

  const _CategoryTab({
    required this.byCategory,
    required this.catColors,
    required this.statusColors,
    required this.onCategoryTap,
  });

  static const Color primaryBlue = Color(0xFF0A1F44);

  @override
  Widget build(BuildContext context) {
    if (byCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No data for selected period",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final categories = byCategory.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "${categories.length} Categor${categories.length != 1 ? 'ies' : 'y'} Active",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          );
        }

        final entry = categories[index - 1];
        final categoryName = entry.key;
        final complaints = entry.value;
        final color = catColors[(index - 1) % catColors.length];

        // Compute status breakdown for this category
        final Map<String, int> catStatus = {
          "Pending": 0,
          "Approved": 0,
          "InProgress": 0,
          "Resolved": 0,
        };
        for (final c in complaints) {
          if (catStatus.containsKey(c.status)) {
            catStatus[c.status] = catStatus[c.status]! + 1;
          }
        }

        final resolved = catStatus["Resolved"]!;
        final total = complaints.length;
        final resRate =
            total > 0 ? ((resolved / total) * 100).toStringAsFixed(0) : "0";

        return _CategoryCard(
          categoryName: categoryName,
          complaints: complaints,
          color: color,
          catStatus: catStatus,
          resolutionRate: resRate,
          statusColors: statusColors,
          onTap: () => onCategoryTap(categoryName),
        );
      },
    );
  }
}

// =============================================================
// CATEGORY CARD (expandable)
// =============================================================
class _CategoryCard extends StatefulWidget {
  final String categoryName;
  final List<Complaint> complaints;
  final Color color;
  final Map<String, int> catStatus;
  final String resolutionRate;
  final Map<String, Color> statusColors;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryName,
    required this.complaints,
    required this.color,
    required this.catStatus,
    required this.resolutionRate,
    required this.statusColors,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.complaints.length;

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
          /// ---- HEADER ROW ----
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  /// Color dot
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.category,
                        color: widget.color, size: 22),
                  ),

                  const SizedBox(width: 14),

                  /// Name + rate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Resolution rate: ${widget.resolutionRate}%",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$total",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          /// ---- EXPANDED DETAIL ----
          if (_expanded) ...[
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Progress bar for each status
                  ...widget.catStatus.entries.map((e) {
                    final pct = total > 0 ? e.value / total : 0.0;
                    final statusColor =
                        widget.statusColors[e.key] ?? Colors.grey;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${e.value} (${(pct * 100).toStringAsFixed(0)}%)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
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
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  /// View complaints button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.color,
                        side: BorderSide(color: widget.color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text(
                        "View Complaints",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// HELPERS
// =============================================================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  static const Color primaryBlue = Color(0xFF0A1F44);

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _PriorityRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            Text(
              "$count (${(pct * 100).toStringAsFixed(0)}%)",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade100,
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}