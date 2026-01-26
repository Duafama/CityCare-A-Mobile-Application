import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DepartmentReportScreen extends StatefulWidget {
  final String department;

  const DepartmentReportScreen({super.key, required this.department});

  @override
  State<DepartmentReportScreen> createState() => _DepartmentReportScreenState();
}

class _DepartmentReportScreenState extends State<DepartmentReportScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  String selectedFilter = "All Time";

  /// ---- Mock data by time filter ----
  final Map<String, Map<String, int>> filterData = {
    "Today": {
      "Pending": 2,
      "In Progress": 1,
      "Approved": 3,
      "Resolved": 2,
      "Rejected": 1,
    },
    "Last Week": {
      "Pending": 6,
      "In Progress": 5,
      "Approved": 8,
      "Resolved": 7,
      "Rejected": 2,
    },
    "Last Month": {
      "Pending": 10,
      "In Progress": 7,
      "Approved": 15,
      "Resolved": 12,
      "Rejected": 4,
    },
    "Last Year": {
      "Pending": 25,
      "In Progress": 20,
      "Approved": 40,
      "Resolved": 35,
      "Rejected": 10,
    },
    "All Time": {
      "Pending": 12,
      "In Progress": 8,
      "Approved": 20,
      "Resolved": 15,
      "Rejected": 5,
    },
  };

  final List<Color> colors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.teal,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    final complaintData = filterData[selectedFilter]!;
    final totalComplaints = complaintData.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.department} Report",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -------- Header --------
            Text(
              widget.department,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Total Complaints: $totalComplaints",
              style: TextStyle(color: Colors.grey[700]),
            ),

            const SizedBox(height: 16),

            /// -------- Filters --------
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filterData.keys.map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  selectedColor: primaryBlue,
                  labelStyle: TextStyle(
                    color: selectedFilter == filter
                        ? Colors.white
                        : Colors.black,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// -------- Bar Chart --------
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, __) {
                        final status = complaintData.keys.elementAt(
                          group.x.toInt(),
                        );
                        final value = complaintData[status]!;
                        final percent = ((value / totalComplaints) * 100)
                            .toStringAsFixed(0);

                        return BarTooltipItem(
                          "$status\n$value Complaints\n$percent%",
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: List.generate(complaintData.length, (index) {
                    final value = complaintData.values.elementAt(index);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: colors[index],
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// -------- Summary --------
            const Text(
              "Complaint Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...complaintData.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final percent = ((item.value / totalComplaints) * 100)
                  .toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "${item.key}: ${item.value} ($percent%)",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
