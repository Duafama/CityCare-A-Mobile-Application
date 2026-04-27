import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/departmentComplaintService.dart';
import '../services/cloudinary_service.dart';

class UploadResolutionScreen extends StatefulWidget {
  const UploadResolutionScreen({super.key});

  @override
  State<UploadResolutionScreen> createState() =>
      _UploadResolutionScreenState();
}

class _UploadResolutionScreenState extends State<UploadResolutionScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  late Complaint complaint;
  bool isLoaded = false;
  bool isSubmitting = false;

  String? selectedImageUrl;
  final TextEditingController notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Complaint) {
        complaint = args;
        isLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imageUrl = await CloudinaryService.pickAndUploadImage();

      if (imageUrl != null) {
        setState(() {
          selectedImageUrl = imageUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitResolution() async {
    setState(() => isSubmitting = true);

    try {
      await DepartmentComplaintService().markResolved(
        complaint.complaintId,
        complaint.citizenId,
        selectedImageUrl!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complaint marked as resolved"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Submission"),
        content: const Text(
          "Mark this complaint as resolved?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitResolution();
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: lightGrey,

      appBar: AppBar(
        title: const Text(
          "Upload Resolution Proof",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Complaint info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                complaint.categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// IMAGE UPLOAD
            const Text(
              "Resolution Image *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedImageUrl != null
                        ? Colors.green
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: selectedImageUrl != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              selectedImageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImageUrl = null;
                                });
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Tap to upload image"),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedImageUrl == null || isSubmitting)
                    ? null
                    : _showConfirmDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Resolution"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}