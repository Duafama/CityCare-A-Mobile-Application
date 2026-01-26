import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Detail")),
      body: ListView(
        children: const [
          ListTile(title: Text("Pending"), trailing: Text("12")),
          ListTile(title: Text("Approved"), trailing: Text("20")),
          ListTile(title: Text("Resolved"), trailing: Text("30")),
        ],
      ),
    );
  }
}
