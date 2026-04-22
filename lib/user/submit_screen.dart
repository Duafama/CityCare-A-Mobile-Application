import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:city_care/services/cloudinary_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'my_complaints_screen.dart';
import 'profile.dart';
import 'dashboard_screen.dart';
// import 'package:city_care/services/geocoding_service.dart';
import 'package:geocoding/geocoding.dart';  // Top par import ka

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

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
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCategory = 'Select a Category';
  String? _selectedCategoryId;
  final List<String> _selectedImageUrls = [];
  bool _isPickingImage = false;
  bool _isSubmitting = false;

  // 🔥 Map variables
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  Set<Marker> _markers = {};

  // 🔥 Categories from Firestore
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _checkLocationPermission();
  }

  // 🔥 Check location permission
  Future<void> _checkLocationPermission() async {
    setState(() => _isLoadingLocation = true);
    
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  // 🔥 Get current location
  Future<void> _getCurrentLocation() async {
  try {
    setState(() => _isLoadingLocation = true);
    
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    final latLng = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _selectedLocation = latLng;
      _updateMarker();
      _locationController.text = 'Getting address...';  // Loading message
    });
    
    // 🔥 Get address from coordinates (FREE)
    final address = await _getAddressFromLatLng(latLng);
    
    setState(() {
      _locationController.text = address;
      _isLoadingLocation = false;
    });
    
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 15.0,
          ),
        ),
      );
    }
  } catch (e) {
    print('Error getting location: $e');
    setState(() => _isLoadingLocation = false);
    _showSnackBar('Error getting location', context);
  }
}
Future<String> _getAddressFromLatLng(LatLng latLng) async {
  try {
    // Convert coordinates to placemark
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latLng.latitude, 
      latLng.longitude,
    );
    
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      
      // Priority order for Pakistan addresses
      String address = '';
      
      // Try to get area name first
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        address = place.subLocality!;  // e.g., "Model Town"
      }
      // Then try locality
      else if (place.locality != null && place.locality!.isNotEmpty) {
        address = place.locality!;  // e.g., "Lahore"
      }
      // Then try sub-administrative area
      else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
        address = place.subAdministrativeArea!;
      }
      // Finally use street or name
      else if (place.name != null && place.name!.isNotEmpty) {
        address = place.name!;
      }
      else {
        address = '${place.street}, ${place.locality}';
      }
      
      // Agar address empty hai to coordinates show karein
      if (address.isEmpty) {
        address = 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
      }
      
      return address;
    }
    
    return 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
    
  } catch (e) {
    print('Geocoding error: $e');
    return 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
  }
}
//
  // 🔥 Update marker on map
  void _updateMarker() {
    if (_selectedLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation!,
          infoWindow: const InfoWindow(title: 'Complaint Location'),
        ),
      );
    }
  }

  // 🔥 Load categories from Firestore
  Future<void> _loadCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();
      
      setState(() {
        _categories = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
          };
        }).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
                  child: _isLoadingCategories
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4A6FFF),
                            ),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF4A6FFF)),
                            items: [
                              const DropdownMenuItem<String>(
                                value: 'Select a Category',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Select a Category',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              ..._categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['name'],
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      category['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: const Color(0xFF0F1A3D),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const DropdownMenuItem<String>(
                                value: 'Other',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Other',
                                    style: TextStyle(
                                      color: Color(0xFF4A6FFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                                if (newValue != 'Select a Category' && newValue != 'Other') {
                                  final selectedCat = _categories.firstWhere(
                                    (cat) => cat['name'] == newValue,
                                    orElse: () => {},
                                  );
                                  _selectedCategoryId = selectedCat['id'];
                                } else {
                                  _selectedCategoryId = null;
                                }
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
                            Icons.my_location,
                            color: Color(0xFF4A6FFF),
                          ),
                          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 🔥 REAL GOOGLE MAP - REPLACES STATIC MAP
                _buildMapSection(),
                
                const SizedBox(height: 20),

                _buildSectionTitle('Attach Images:'),
                const SizedBox(height: 8),
                _buildImagePickerSection(),
                const SizedBox(height: 20),

                // 🔍 AI Duplication Detection - TO BE IMPLEMENTED
                // ⚡ AI Priority Suggestion - TO BE IMPLEMENTED

                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6FFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
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

  // 🔥 REAL GOOGLE MAP WIDGET
  Widget _buildMapSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(31.5204, 74.3587),
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_selectedLocation != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _selectedLocation!,
                        zoom: 15,
                      ),
                    ),
                  );
                }
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              onTap: (LatLng latLng) async {  // 👈 "async" add kiya
  setState(() {
    _selectedLocation = latLng;
    _locationController.text = 'Getting address...';  // Loading message
    _updateMarker();
  });
  
  // Address fetch karein
  final address = await _getAddressFromLatLng(latLng);
  
  setState(() {
    _locationController.text = address;
  });
},
            ),
            
            if (_isLoadingLocation)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, color: Color(0xFF4A6FFF), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Tap on map to select location',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

        if (_selectedImageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Selected Images (${_selectedImageUrls.length}):',
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
              itemCount: _selectedImageUrls.length,
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
                          image: NetworkImage(_selectedImageUrls[index]),
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

    try {
      final imageUrl = await CloudinaryService.pickAndUploadImage();
      
      if (imageUrl != null && mounted) {
        setState(() {
          _selectedImageUrls.add(imageUrl);
        });
        _showSnackBar('Image uploaded successfully!', context);
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Error uploading image', context);
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImageUrls.removeAt(index);
    });
    _showSnackBar('Image removed!', context);
  }

  Future<void> _submitComplaint() async {
    if (_selectedCategory == 'Select a Category') {
      _showSnackBar('Please select a category', context);
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showSnackBar('Please provide a description', context);
      return;
    }

    if (_selectedLocation == null) {
      _showSnackBar('Please select a location on map', context);
      return;
    }

    if (_currentUser == null) {
      _showSnackBar('You must be logged in to submit a complaint', context);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String complaintId = FirebaseFirestore.instance
          .collection('complaints')
          .doc()
          .id;

      String suggestedPriority = 'Medium';

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .set({
        'complaintId': complaintId,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'beforeImages': _selectedImageUrls,
        'afterImages': [],
        'status': 'Pending',
        'priority': suggestedPriority,
        'createdAt': FieldValue.serverTimestamp(),
        'citizenId': _currentUser!.uid,
        'citizenEmail': _currentUser!.email,
        'categoryId': _selectedCategoryId ?? '',
        'categoryName': _selectedCategory == 'Other' ? 'Other' : _selectedCategory,
        'departmentId': '',
        'upvoteCount': 0,
        'commentCount': 0,
      });

      _showSnackBar('✅ Complaint submitted successfully!', context);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _selectedCategory = 'Select a Category';
            _selectedCategoryId = null;
            _descriptionController.clear();
            _locationController.clear();
            _selectedLocation = null;
            _markers.clear();
            _selectedImageUrls.clear();
            _isSubmitting = false;
          });
        }
      });

    } catch (e) {
      print('Error submitting complaint: $e');
      _showSnackBar('Error submitting complaint: ${e.toString()}', context);
      setState(() => _isSubmitting = false);
    }
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

void _handleNavigation(int index, BuildContext context) {
  switch (index) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      break;
    case 1:
      break;
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyComplaintsScreen()),
      );
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      break;
  }
}