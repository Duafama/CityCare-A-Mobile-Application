import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_department.dart';
import 'department_detail.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() =>
      _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Manage Departments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDepartmentScreen()),
          ).then((_) {
            // Refresh if needed
            setState(() {});
          });
        },
      ),
      body: Column(
        children: [
          /// ---------------- SEARCH BAR ----------------
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search input
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search departments by name...",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// ---------------- TOTAL COUNT CARD ----------------
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('departments').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    var docs = snapshot.data!.docs;

                    // Filter departments based on search query for count
                    if (_searchQuery.isNotEmpty) {
                      docs = docs.where((doc) {
                        final deptName =
                            doc['name']?.toString().toLowerCase() ?? '';
                        final query = _searchQuery.toLowerCase();
                        return deptName.contains(query);
                      }).toList();
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryBlue,
                            primaryBlue.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Total Departments",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${docs.length}",
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          /// ---------------- DEPARTMENTS LIST ----------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('departments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error loading departments",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Filter departments based on search query
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final deptName =
                        doc['name']?.toString().toLowerCase() ?? '';
                    final query = _searchQuery.toLowerCase();
                    return deptName.contains(query);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.business_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? "No departments found for \"$_searchQuery\""
                              : "No departments found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text("Clear Search"),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final dept = docs[index];
                    final status = (dept['status'] ?? 'active');
                    final deptName = dept['name'] ?? '';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DepartmentDetailScreen(
                                deptId: dept.id,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.apartment,
                                  color: primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                        children: _highlightText(
                                          deptName,
                                          _searchQuery,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == "active"
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status == "active"
                                            ? "Active"
                                            : "Inactive",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: status == "active"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                status == "active"
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: status == "active"
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to highlight matching text
  List<TextSpan> _highlightText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // Add remaining text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );

      start = index + query.length;
    }

    return spans;
  }
}
