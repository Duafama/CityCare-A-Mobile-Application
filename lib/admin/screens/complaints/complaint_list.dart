import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/complaint_enums.dart';
import '../../app_routes.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  ComplaintStatus? selectedStatus;
  String? selectedCategory;
  String? sortOrder;
  String searchQuery = "";

  List<String> categories = [];
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> sortOptions = [
    {"value": "date_new_old", "label": "Date ↓"},
    {"value": "date_old_new", "label": "Date ↑"},
    {"value": "priority_low_high", "label": "Priority ↑"},
    {"value": "priority_high_low", "label": "Priority ↓"},
    {"value": "name_a_z", "label": "A → Z"},
    {"value": "name_z_a", "label": "Z → A"},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is ComplaintStatus) {
      selectedStatus = arg;
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snap =
        await FirebaseFirestore.instance.collection('categories').get();

    setState(() {
      categories = snap.docs.map((e) => e['name'].toString()).toList();
    });
  }

  Stream<QuerySnapshot> _stream() {
    if (selectedStatus == null) {
      return FirebaseFirestore.instance.collection('complaints').snapshots();
    }

    return FirebaseFirestore.instance
        .collection('complaints')
        .where('status', isEqualTo: selectedStatus!.value)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          selectedStatus?.value ?? "All Complaints",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= SEARCH BAR =================
            _buildSearchBar(),

            const SizedBox(height: 12),

            /// ================= FILTER + SORT =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCategoryDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildSortDropdown()),
              ],
            ),

            const SizedBox(height: 12),

            /// ================= LIST HEADER WITH COUNT =================
            _buildListHeader(),

            const SizedBox(height: 12),

            /// ================= LIST =================
            Expanded(
              child: _buildComplaintList(),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SEARCH BAR =================
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                hintText: "Search by category, department, or ID...",
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
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                size: 18,
                color: Colors.grey[500],
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = "";
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// ================= LIST HEADER WITH COUNT =================
  Widget _buildListHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        var docs = snapshot.data!.docs;

        /// Apply filters to get count
        var filteredList = docs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;

          // Category filter
          if (selectedCategory != null &&
              d['categoryName'] != selectedCategory) {
            return false;
          }

          // Search filter
          if (searchQuery.isNotEmpty) {
            final categoryName =
                d['categoryName']?.toString().toLowerCase() ?? '';
            final departmentName =
                d['departmentName']?.toString().toLowerCase() ?? '';
            final complaintId =
                d['complaintId']?.toString().toLowerCase() ?? '';
            final query = searchQuery.toLowerCase();

            return categoryName.contains(query) ||
                departmentName.contains(query) ||
                complaintId.contains(query);
          }

          return true;
        }).toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_list_bulleted,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Total Complaints",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1F44),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${filteredList.length}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= COMPLAINT LIST =================
  Widget _buildComplaintList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream(),
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
                  "Error loading complaints",
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

        /// FILTER BY CATEGORY AND SEARCH
        var list = docs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;

          // Category filter
          if (selectedCategory != null &&
              d['categoryName'] != selectedCategory) {
            return false;
          }

          // Search filter
          if (searchQuery.isNotEmpty) {
            final categoryName =
                d['categoryName']?.toString().toLowerCase() ?? '';
            final departmentName =
                d['departmentName']?.toString().toLowerCase() ?? '';
            final complaintId =
                d['complaintId']?.toString().toLowerCase() ?? '';
            final description =
                d['description']?.toString().toLowerCase() ?? '';
            final query = searchQuery.toLowerCase();

            return categoryName.contains(query) ||
                departmentName.contains(query) ||
                complaintId.contains(query) ||
                description.contains(query);
          }

          return true;
        }).toList();

        /// SORT
        list.sort((a, b) {
          final x = a.data() as Map<String, dynamic>;
          final y = b.data() as Map<String, dynamic>;

          switch (sortOrder) {
            case "name_a_z":
              return x['categoryName']
                  .toString()
                  .toLowerCase()
                  .compareTo(y['categoryName'].toString().toLowerCase());

            case "name_z_a":
              return y['categoryName']
                  .toString()
                  .toLowerCase()
                  .compareTo(x['categoryName'].toString().toLowerCase());

            case "priority_high_low":
              return _getPriorityValue(y['priority'])
                  .compareTo(_getPriorityValue(x['priority']));

            case "priority_low_high":
              return _getPriorityValue(x['priority'])
                  .compareTo(_getPriorityValue(y['priority']));

            case "date_new_old":
              final xDate = x['createdAt'] as Timestamp?;
              final yDate = y['createdAt'] as Timestamp?;
              if (xDate == null && yDate == null) return 0;
              if (xDate == null) return 1;
              if (yDate == null) return -1;
              return yDate.compareTo(xDate);

            case "date_old_new":
              final xDate = x['createdAt'] as Timestamp?;
              final yDate = y['createdAt'] as Timestamp?;
              if (xDate == null && yDate == null) return 0;
              if (xDate == null) return 1;
              if (yDate == null) return -1;
              return xDate.compareTo(yDate);
          }
          return 0;
        });

        if (list.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final d = list[index].data() as Map<String, dynamic>;
            final id = list[index].id;

            return _buildComplaintCard(d, id);
          },
        );
      },
    );
  }

  /// ================= STYLED CATEGORY DROPDOWN =================
  Widget _buildCategoryDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedCategory,
        hint: Row(
          children: [
            Icon(Icons.category_outlined, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Category",
                style: TextStyle(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Row(
              children: [
                Icon(Icons.view_list, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "All Categories",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...categories.map((category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(Icons.label_outline,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
        onChanged: (v) => setState(() => selectedCategory = v),
      ),
    );
  }

  /// ================= STYLED SORT DROPDOWN =================
  Widget _buildSortDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: sortOrder,
        hint: Row(
          children: [
            Icon(Icons.sort_by_alpha, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Sort",
                style: TextStyle(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items: sortOptions.map((o) {
          return DropdownMenuItem(
            value: o['value'],
            child: Row(
              children: [
                Icon(_getSortIcon(o['value']!),
                    size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    o['label']!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => sortOrder = v),
      ),
    );
  }

  IconData _getSortIcon(String sortValue) {
    switch (sortValue) {
      case "date_new_old":
        return Icons.arrow_downward;
      case "date_old_new":
        return Icons.arrow_upward;
      case "priority_high_low":
        return Icons.trending_down;
      case "priority_low_high":
        return Icons.trending_up;
      case "name_a_z":
        return Icons.sort_by_alpha;
      case "name_z_a":
        return Icons.sort_by_alpha_outlined;
      default:
        return Icons.sort;
    }
  }

  /// ================= STYLED COMPLAINT CARD =================
  Widget _buildComplaintCard(Map<String, dynamic> complaint, String id) {
    // Check if status is pending to hide department
    final isPending =
        complaint['status']?.toString().toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.complaintDetail,
              arguments: id,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          children: _highlightText(
                            complaint['categoryName'] ?? 'Uncategorized',
                            searchQuery,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(complaint['priority'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        complaint['priority'] ?? 'Low',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(complaint['priority']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Only show department if status is not pending
                if (!isPending) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            children: _highlightText(
                              complaint['departmentName'] ?? 'No department',
                              searchQuery,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                // Show date
                if (complaint['createdAt'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(complaint['createdAt']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
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
          ),
        ),
      );

      start = index + query.length;
    }

    return spans;
  }

  /// ================= EMPTY STATE =================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No complaints found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? "No results for \"$searchQuery\""
                : (selectedCategory != null
                    ? "No complaints in $selectedCategory category"
                    : "Try changing your filters"),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = "";
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text("Clear Search"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0A1F44),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ================= HELPER METHODS =================
  int _getPriorityValue(String p) {
    switch (p.toLowerCase()) {
      case "low":
        return 1;
      case "medium":
        return 2;
      case "high":
        return 3;
      default:
        return 0;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
