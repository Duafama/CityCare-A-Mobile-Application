import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'department_navigation.dart';

class DepartmentReportsScreen extends StatefulWidget {
  const DepartmentReportsScreen({super.key});

  @override
  State<DepartmentReportsScreen> createState() =>
      _DepartmentReportsScreenState();
}

class _DepartmentReportsScreenState extends State<DepartmentReportsScreen> {
  final int _currentIndex = 2;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  String selectedPeriod = "This Month";

  final List<String> periods = [
    "This Week",
    "This Month",
    "This Quarter",
    "This Year",
  ];

  /// ---- Mock data by time period ----
  final Map<String, Map<String, int>> periodData = {
    "This Week": {
      "New": 2,
      "Approved": 3,
      "In Progress": 1,
      "Resolved": 2,
    },
    "This Month": {
      "New": 8,
      "Approved": 10,
      "In Progress": 5,
      "Resolved": 14,
    },
    "This Quarter": {
      "New": 15,
      "Approved": 25,
      "In Progress": 12,
      "Resolved": 35,
    },
    "This Year": {
      "New": 45,
      "Approved": 80,
      "In Progress": 30,
      "Resolved": 120,
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
    final complaintData = periodData[selectedPeriod]!;
    final totalComplaints = complaintData.values.reduce((a, b) => a + b);

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
      ),

      /// ---------------- Body ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -------- Header --------
            const Text(
              "Sanitation Department",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Total Complaints: $totalComplaints",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            /// -------- Period Filters --------
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: periods.map((period) {
                return ChoiceChip(
                  label: Text(period),
                  selected: selectedPeriod == period,
                  onSelected: (_) {
                    setState(() {
                      selectedPeriod = period;
                    });
                  },
                  selectedColor: primaryBlue,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedPeriod == period ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            /// -------- Bar Chart --------
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         blurRadius: 8,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         "Complaint Distribution",
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //           color: primaryBlue,
            //         ),
            //       ),
            //       const SizedBox(height: 20),
            //       Container(
            //         height: 260,
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: Colors.grey.shade50,
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: BarChart(
            //           BarChartData(
            //             gridData: FlGridData(
            //               show: true,
            //               drawVerticalLine: false,
            //               horizontalInterval: selectedPeriod == "This Week" ? 1 : 
            //                                  selectedPeriod == "This Month" ? 5 :
            //                                  selectedPeriod == "This Quarter" ? 10 : 20,
            //               getDrawingHorizontalLine: (value) {
            //                 return FlLine(
            //                   color: Colors.grey.shade300,
            //                   strokeWidth: 1,
            //                 );
            //               },
            //             ),
            //             borderData: FlBorderData(show: false),
            //             barTouchData: BarTouchData(
            //               enabled: true,
            //               touchTooltipData: BarTouchTooltipData(
            //                 getTooltipColor: (group) => primaryBlue,
            //                 getTooltipItem: (group, _, rod, __) {
            //                   final status = complaintData.keys.elementAt(
            //                     group.x.toInt(),
            //                   );
            //                   final value = complaintData[status]!;
            //                   final percent = ((value / totalComplaints) * 100)
            //                       .toStringAsFixed(0);

            //                   return BarTooltipItem(
            //                     "$status\n$value Complaints\n$percent%",
            //                     const TextStyle(
            //                       color: Colors.white,
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 12,
            //                     ),
            //                   );
            //                 },
            //               ),
            //             ),
            //             titlesData: FlTitlesData(
            //               topTitles: const AxisTitles(
            //                 sideTitles: SideTitles(showTitles: false),
            //               ),
            //               rightTitles: const AxisTitles(
            //                 sideTitles: SideTitles(showTitles: false),
            //               ),
            //               bottomTitles: AxisTitles(
            //                 sideTitles: SideTitles(
            //                   showTitles: true,
            //                   getTitlesWidget: (value, meta) {
            //                     final status = complaintData.keys.elementAt(
            //                       value.toInt(),
            //                     );
            //                     return Padding(
            //                       padding: const EdgeInsets.only(top: 8),
            //                       child: Text(
            //                         status,
            //                         style: TextStyle(
            //                           color: Colors.grey[700],
            //                           fontSize: 11,
            //                           fontWeight: FontWeight.w600,
            //                         ),
            //                       ),
            //                     );
            //                   },
            //                 ),
            //               ),
            //               leftTitles: AxisTitles(
            //                 sideTitles: SideTitles(
            //                   showTitles: true,
            //                   reservedSize: 35,
            //                   getTitlesWidget: (value, meta) {
            //                     return Text(
            //                       value.toInt().toString(),
            //                       style: TextStyle(
            //                         color: Colors.grey[600],
            //                         fontSize: 11,
            //                       ),
            //                     );
            //                   },
            //                 ),
            //               ),
            //             ),
            //             barGroups: List.generate(complaintData.length, (index) {
            //               final value = complaintData.values.elementAt(index);
            //               return BarChartGroupData(
            //                 x: index,
            //                 barRods: [
            //                   BarChartRodData(
            //                     toY: value.toDouble(),
            //                     width: 24,
            //                     borderRadius: const BorderRadius.vertical(
            //                       top: Radius.circular(6),
            //                     ),
            //                     color: statusColors[index],
            //                   ),
            //                 ],
            //               );
            //             }),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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

            /// -------- Complaint Summary --------
            // const Text(
            //   "Complaint Summary",
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: primaryBlue,
            //   ),
            // ),
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

            const SizedBox(height: 28),

            /// -------- Category Breakdown --------
            const Text(
              "Complaints by Category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            _buildCategoryCard("Water Supply", 8, Colors.blue),
            _buildCategoryCard("Drainage", 6, Colors.teal),
            _buildCategoryCard("Street Cleaning", 5, Colors.green),
            _buildCategoryCard("Others", 4, Colors.grey),
          ],
        ),
      ),

      /// ---------------- Bottom Nav ----------------
      bottomNavigationBar: departmentBottomNav(context, _currentIndex),
    );
  }

  Widget _buildCategoryCard(String category, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.category, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}