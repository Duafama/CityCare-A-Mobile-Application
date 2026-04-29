import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';

class EditComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const EditComplaintScreen({super.key, required this.complaint});

  @override
  State<EditComplaintScreen> createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late String _selectedCategory;
  List<String> _selectedImages = [];
  bool _isSaving = false;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.complaint['description'] ?? '');
    _locationController = TextEditingController(text: widget.complaint['location'] ?? '');
    _selectedCategory = widget.complaint['categoryName'] ?? widget.complaint['category'] ?? 'Other';
    _selectedImages = List<String>.from(widget.complaint['beforeImages'] ?? widget.complaint['images'] ?? []);
    _loadCategories();
    double? lat = widget.complaint['latitude'];
    double? lng = widget.complaint['longitude'];
    if (lat != null && lng != null) {
      _selectedLocation = LatLng(lat, lng);
      _updateMarker();
    }
    _checkLocationPermission();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoadingCategories = true);
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('status', isEqualTo: 'active')
          .get();

      if (snapshot.docs.isEmpty) {
        QuerySnapshot allDocs = await FirebaseFirestore.instance.collection('categories').get();
        List<Map<String, dynamic>> activeCategories = [];
        for (var doc in allDocs.docs) {
          String status = doc['status'] ?? '';
          if (status.toLowerCase() == 'active') {
            activeCategories.add({'id': doc.id, 'name': doc['name']});
          }
        }
        setState(() {
          _categories = activeCategories;
          if (!_categories.any((c) => c['name'] == 'Other')) {
            _categories.add({'id': 'other', 'name': 'Other'});
          }
          // ✅ Fix: Ensure selected category exists in list
          if (!_categories.any((cat) => cat['name'] == _selectedCategory)) {
            _selectedCategory = _categories.isNotEmpty ? _categories.first['name'] : 'Other';
          }
          _isLoadingCategories = false;
        });
        return;
      }

      setState(() {
        _categories = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
        if (!_categories.any((c) => c['name'] == 'Other')) {
          _categories.add({'id': 'other', 'name': 'Other'});
        }
        // ✅ Fix: Ensure selected category exists in list
        if (!_categories.any((cat) => cat['name'] == _selectedCategory)) {
          _selectedCategory = _categories.isNotEmpty ? _categories.first['name'] : 'Other';
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categories = [{'id': 'other', 'name': 'Other'}];
        _selectedCategory = 'Other'; // fallback
        _isLoadingCategories = false;
      });
    }
  }
// ✅ YAHAN PE LAGAYEIN
  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select Category',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(),
              ..._categories.map((cat) {
                bool isSelected = cat['name'] == _selectedCategory;
                return ListTile(
                  leading: Icon(
                    Icons.circle,
                    size: 12,
                    color: isSelected ? const Color(0xFF4A6FFF) : Colors.grey[400],
                  ),
                  title: Text(
                    cat['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF4A6FFF))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'];
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
  
  
  
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) await Permission.location.request();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = latLng;
        _updateMarker();
        _locationController.text = 'Getting address...';
      });
      final address = await _getAddressFromLatLng(latLng);
      setState(() {
        _locationController.text = address;
        _isLoadingLocation = false;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation!, zoom: 15)));
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      _showSnackBar('Error getting location');
    }
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (place.subLocality != null && place.subLocality!.isNotEmpty) return place.subLocality!;
        if (place.locality != null && place.locality!.isNotEmpty) return place.locality!;
        if (place.name != null && place.name!.isNotEmpty) return place.name!;
        return '${place.street}, ${place.locality}';
      }
      return 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
    } catch (e) {
      return 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
    }
  }

  void _updateMarker() {
    if (_selectedLocation != null) {
      _markers.clear();
      _markers.add(Marker(markerId: const MarkerId('selected_location'), position: _selectedLocation!,
          infoWindow: const InfoWindow(title: 'Complaint Location')));
    }
  }

  Future<void> _saveChanges() async {
    if (_descriptionController.text.isEmpty) {
      _showSnackBar('Please enter a description');
      return;
    }
    if (_locationController.text.isEmpty) {
      _showSnackBar('Please enter a location');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showSnackBar('Please add at least one image');
      return;
    }
    setState(() => _isSaving = true);
    try {
      String complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];
      Map<String, dynamic> updateData = {
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'categoryName': _selectedCategory,
        'beforeImages': _selectedImages,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_selectedLocation != null) {
        updateData['latitude'] = _selectedLocation!.latitude;
        updateData['longitude'] = _selectedLocation!.longitude;
      }
      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).update(updateData);
      if (mounted) {
        _showSnackBar('Complaint updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() => _isSaving = true);
    try {
      File imageFile = File(pickedFile.path);
      final imageUrl = await CloudinaryService.uploadImage(imageFile);
      if (imageUrl != null && mounted) {
        setState(() => _selectedImages.add(imageUrl));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
    _showSnackBar('Image removed! (Save to update)');
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A3D),
        elevation: 0,
        centerTitle: true,
        title: Text('Edit Complaint', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Complaint Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
                  const SizedBox(height: 20),
                  // Category ke liye jo purani DropdownButton wali code hai, uski jagah ye lagayein:

_buildLabel('Category:'),
const SizedBox(height: 8),
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey[200]!, width: 1.5),
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8)],
  ),
  child: _isLoadingCategories
      ? const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF4A6FFF))),
        )
      : GestureDetector(
          onTap: () => _showCategoryBottomSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF4A6FFF), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
  child: Text(
    _selectedCategory,
    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF0F1A3D)),
    overflow: TextOverflow.ellipsis,
  ),
),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.arrow_drop_down, color: Color(0xFF4A6FFF), size: 24),
                ),
              ],
            ),
          ),
        ),
),
                  const SizedBox(height: 20),
                  _buildLabel('Description:'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Update your complaint description',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF0F1A3D)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Location:'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Select location on map',
                              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                              prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF4A6FFF)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF0F1A3D)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.my_location, color: Color(0xFF4A6FFF)),
                          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMapSection(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complaint Images', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
                  const SizedBox(height: 15),
                  if (_selectedImages.isNotEmpty) ...[
                    Text('Current Images (${_selectedImages.length}):', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F1A3D))),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) => Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: NetworkImage(_selectedImages[index]), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4A6FFF), Color(0xFF5BC0DE)]), borderRadius: BorderRadius.circular(12)),
                    child: ElevatedButton(
                      onPressed: _addImage,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, shadowColor: Colors.transparent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text('Add New Image', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4A6FFF), Color(0xFF5BC0DE)]), borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: const Color(0xFF4A6FFF).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)]),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, shadowColor: Colors.transparent),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, size: 22),
                          const SizedBox(width: 10),
                          Text('Save Changes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _selectedLocation ?? const LatLng(31.5204, 74.3587), zoom: _selectedLocation != null ? 15 : 12),
              onMapCreated: (GoogleMapController controller) => _mapController = controller,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              onTap: (LatLng latLng) async {
                setState(() {
                  _selectedLocation = latLng;
                  _locationController.text = 'Getting address...';
                  _updateMarker();
                });
                final address = await _getAddressFromLatLng(latLng);
                setState(() => _locationController.text = address);
              },
            ),
            if (_isLoadingLocation)
              Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, color: Color(0xFF4A6FFF), size: 16),
                    const SizedBox(width: 4),
                    Text('Tap on map to select location', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F1A3D)));
}