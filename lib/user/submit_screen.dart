import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_complaints_screen.dart';
import 'profile.dart';
import 'dashboard_screen.dart';
class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A3D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Submit Complaint',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const SubmitContent(),
      
      // SAME navigation as dashboard
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Always show Submit selected
        onTap: (index) {
          _handleNavigation(index, context);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0F1A3D),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class SubmitContent extends StatefulWidget {
  const SubmitContent({super.key});

  @override
  State<SubmitContent> createState() => _SubmitContentState();
}

class _SubmitContentState extends State<SubmitContent> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCategory = 'Select a Category';
  final List<String> _selectedImagePaths = [];
  bool _showMapPlaceholder = false;
  bool _isPickingImage = false;

  final List<String> _categories = [
    'Select a Category',
    'Broken Streetlight',
    'Water Leakage',
    'Garbage Pile Up',
    'Potholes',
    'Drainage Issue',
    'Road Damage',
    'Public Park Issue',
    'Street Cleaning',
    'Other'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Category:'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF4A6FFF)),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: category == 'Select a Category'
                                    ? Colors.grey[500]
                                    : const Color(0xFF0F1A3D),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Description:'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Provide a detailed information about the issue',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF0F1A3D),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Location:'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: 'Address or Location of the issue',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF0F1A3D),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.location_on,
                            color: Color(0xFF4A6FFF),
                          ),
                          onPressed: () {
                            setState(() {
                              _locationController.text =
                                  '123 Civil Lines, Gujranwala';
                              _showMapPlaceholder = true;
                            });
                            _showSnackBar('Location added!', context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _locationController.text =
                          'Current Location: Gujranwala, Pakistan';
                      _showMapPlaceholder = true;
                    });
                    _showSnackBar('Using your current location!', context);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Color(0xFF4A6FFF), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '📍 Use my location',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF4A6FFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_showMapPlaceholder) ...[
                  const SizedBox(height: 16),
                  _buildStaticMapUI(),
                ],

                const SizedBox(height: 20),

                _buildSectionTitle('Attach Images:'),
                const SizedBox(height: 8),
                _buildImagePickerSection(),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6FFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Complaint',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F1A3D),
      ),
    );
  }

  Widget _buildStaticMapUI() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE8F5E9),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Gujranwala, Pakistan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: MapPainter(),
                      ),

                      Positioned(
                        top: 60,
                        left: MediaQuery.of(context).size.width / 2 - 15,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1A3D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '📍',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 2,
                              color: const Color(0xFF0F1A3D),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.explore,
                            color: Color(0xFF4A6FFF),
                            size: 20,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF0F1A3D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Color(0xFF0F1A3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4A6FFF),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap and drag to move map',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(12),
            child: _isPickingImage
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A6FFF),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Color(0xFF4A6FFF),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Images',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: const Color(0xFF4A6FFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '(Tap to select images)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (_selectedImagePaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Selected Images (${_selectedImagePaths.length}):',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F1A3D),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImagePaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_selectedImagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImages() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final demoImages = [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1518495978945-83d413a61108?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1558640476-437a2e9b7a2f?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ];

      setState(() {
        _selectedImagePaths.addAll(demoImages);
      });

      _showSnackBar('${demoImages.length} images added successfully!', context);
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Error adding images', context);
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
    _showSnackBar('Image removed!', context);
  }

  void _submitComplaint() {
    if (_selectedCategory == 'Select a Category') {
      _showSnackBar('Please select a category', context);
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showSnackBar('Please provide a description', context);
      return;
    }

    if (_locationController.text.isEmpty) {
      _showSnackBar('Please provide a location', context);
      return;
    }

    _showSnackBar('✅ Complaint submitted successfully!', context);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _selectedCategory = 'Select a Category';
        _descriptionController.clear();
        _locationController.clear();
        _selectedImagePaths.clear();
        _showMapPlaceholder = false;
      });
    });
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A6FFF),
      ),
    );
  }
}

// Navigation function (same for all screens)
void _handleNavigation(int index, BuildContext context) {
  switch (index) {
    case 0: // Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      break;
    case 1: // Submit
      // Already here
      break;
    case 2: // My Complaints
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyComplaintsScreen()),
      );
      break;
    case 3: // Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      break;
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.3),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.1),
      Offset(size.width * 0.4, size.height * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.6),
      paint,
    );

    final buildingPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromPoints(
        Offset(size.width * 0.2, size.height * 0.4),
        Offset(size.width * 0.3, size.height * 0.6),
      ),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromPoints(
        Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width * 0.7, size.height * 0.7),
      ),
      buildingPaint,
    );

    final parkPaint = Paint()
      ..color = const Color(0xFFC8E6C9)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromPoints(
        Offset(size.width * 0.1, size.height * 0.6),
        Offset(size.width * 0.4, size.height * 0.8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}