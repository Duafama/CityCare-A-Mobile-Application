import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../providers/department_provider.dart';
import 'department_navigation.dart';
import 'department_routes.dart';

class DepartmentCategoriesScreen extends StatefulWidget {
  const DepartmentCategoriesScreen({super.key});

  @override
  State<DepartmentCategoriesScreen> createState() =>
      _DepartmentCategoriesScreenState();
}

class _DepartmentCategoriesScreenState
    extends State<DepartmentCategoriesScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final int _currentIndex = 1;

  List<Category> categories = [];
  bool isLoading = true;

  /// Color palette cycled per card so categories look distinct
  final List<Color> _cardColors = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFF00897B),
    Color(0xFFFFA726),
    Color(0xFF8E24AA),
    Color(0xFFE53935),
    Color(0xFF039BE5),
    Color(0xFF6D4C41),
  ];

  final List<IconData> _cardIcons = [
    Icons.construction,
    Icons.local_florist,
    Icons.water_drop,
    Icons.electrical_services,
    Icons.cleaning_services,
    Icons.traffic,
    Icons.health_and_safety,
    Icons.park,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final departmentId =
          context.read<DepartmentProvider>().departmentId;

      if (departmentId == null) return;

      final data =
          await CategoryService().getCategoriesByDepartment(departmentId);

      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),

      /// ---------------- Body ----------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No categories assigned",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${categories.length} Categor${categories.length != 1 ? 'ies' : 'y'} Assigned",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final color =
                                _cardColors[index % _cardColors.length];
                            final icon =
                                _cardIcons[index % _cardIcons.length];

                            return _CategoryCard(
                              category: category,
                              color: color,
                              icon: icon,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  DepartmentRoutes.list,
                                  arguments: {
                                    'categoryFilter': category.name,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

      /// ---------------- Bottom Nav ----------------
      bottomNavigationBar: departmentBottomNav(context, _currentIndex),
    );
  }
}

/// ---------------- Category Card ----------------
class _CategoryCard extends StatelessWidget {
  final Category category;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),

            const SizedBox(height: 10),

            Flexible(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "View Complaints",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}