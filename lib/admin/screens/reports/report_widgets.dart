import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ─────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────
const Color kPrimaryBlue = Color(0xFF0A1F44);
const Color kLightGrey = Color(0xFFF4F6F8);

const Map<String, Color> kStatusColors = {
  "Pending": Color(0xFFFFA726),
  "Approved": Color(0xFF1E88E5),
  "InProgress": Color(0xFF43A047),
  "Resolved": Color(0xFF00897B),
  "Rejected": Color(0xFFE53935),
};

const Map<String, Color> kPriorityColors = {
  "High": Color(0xFFE53935),
  "Medium": Color(0xFFFFA726),
  "Low": Color(0xFF43A047),
};

const List<Color> kCategoryPalette = [
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFF00897B),
  Color(0xFFFFA726),
  Color(0xFF8E24AA),
  Color(0xFFE53935),
  Color(0xFF039BE5),
  Color(0xFF6D4C41),
];

const List<String> kPeriods = [
  "Today",
  "This Week",
  "This Month",
  "This Year",
  "All Time",
];

// ─────────────────────────────────────────────────────────────
// PERIOD FILTER CHIPS
// ─────────────────────────────────────────────────────────────
class PeriodFilterBar extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;

  const PeriodFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: kPeriods.map((p) {
            final bool isSelected = selected == p;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p),
                selected: isSelected,
                selectedColor: kPrimaryBlue,
                backgroundColor: kLightGrey,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                onSelected: (_) => onSelected(p),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAT CARD (icon + count + label)
// ─────────────────────────────────────────────────────────────
class ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ReportStatCard({
    super.key,
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
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

// ─────────────────────────────────────────────────────────────
// STATUS BAR CHART
// ─────────────────────────────────────────────────────────────
class StatusBarChart extends StatelessWidget {
  final Map<String, int> statusCounts;
  final int total;

  const StatusBarChart({
    super.key,
    required this.statusCounts,
    required this.total,
  });

  static const List<String> _labels = [
    "Pending",
    "Approved",
    "In Prog.",
    "Resolved",
    "Rejected",
  ];

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text("No data", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status Distribution",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => kPrimaryBlue,
                    getTooltipItem: (group, _, rod, __) {
                      final key =
                          statusCounts.keys.elementAt(group.x.toInt());
                      final val = statusCounts[key]!;
                      final pct = total > 0
                          ? ((val / total) * 100).toStringAsFixed(0)
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
                        final i = value.toInt();
                        if (i < 0 || i >= _labels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _labels[i],
                            style: const TextStyle(
                              fontSize: 9,
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
                barGroups: statusCounts.entries
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.value.toDouble(),
                            color: kStatusColors[e.value.key] ??
                                Colors.grey,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: statusCounts.entries.map((e) {
              final pct = total > 0
                  ? ((e.value / total) * 100).toStringAsFixed(0)
                  : "0";
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: kStatusColors[e.key] ?? Colors.grey,
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRIORITY PROGRESS ROW
// ─────────────────────────────────────────────────────────────
class PriorityProgressSection extends StatelessWidget {
  final Map<String, int> priorityCounts;
  final int total;

  const PriorityProgressSection({
    super.key,
    required this.priorityCounts,
    required this.total,
  });

  static const Map<String, IconData> _icons = {
    "High": Icons.arrow_upward,
    "Medium": Icons.remove,
    "Low": Icons.arrow_downward,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Priority Breakdown",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          ...["High", "Medium", "Low"].map((p) {
            final count = priorityCounts[p] ?? 0;
            final pct = total > 0 ? count / total : 0.0;
            final color = kPriorityColors[p]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
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
                            child: Icon(_icons[p], color: color, size: 13),
                          ),
                          const SizedBox(width: 8),
                          Text(p,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                      Text(
                        "$count (${(pct * 100).toStringAsFixed(0)}%)",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.shade100,
                      color: color,
                      minHeight: 9,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
        ],
      ),
    );
  }
}