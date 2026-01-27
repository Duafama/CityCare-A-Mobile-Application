import 'package:flutter/material.dart';

class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  String status = "In Progress";
  bool imageUploaded = false;
  String? remarks;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final TextEditingController remarksController = TextEditingController();

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Update Status",
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
            /// -------- STATUS DROPDOWN --------
            const Text(
              "Select Status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                items: const [
                  DropdownMenuItem(
                    value: "In Progress",
                    child: Row(
                      children: [
                        Icon(Icons.autorenew, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Text("In Progress"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Resolved",
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 12),
                        Text("Resolved"),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value!;
                    if (status != "Resolved") {
                      imageUploaded = false;
                    }
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            /// -------- REMARKS --------
            const Text(
              "Remarks (Optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: remarksController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Add any notes or comments...",
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    remarks = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            /// -------- RESOLVED IMAGE UPLOAD --------
            if (status == "Resolved") ...[
              const Text(
                "Resolution Proof",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: imageUploaded ? Colors.green : Colors.red.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      imageUploaded ? Icons.check_circle : Icons.camera_alt,
                      size: 60,
                      color: imageUploaded ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      imageUploaded
                          ? "Image uploaded successfully"
                          : "Upload resolution photo",
                      style: TextStyle(
                        fontSize: 14,
                        color: imageUploaded ? Colors.green : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          imageUploaded = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Image uploaded successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: imageUploaded ? Colors.grey : primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.upload),
                      label: Text(imageUploaded ? "Change Image" : "Upload Image"),
                    ),
                  ],
                ),
              ),

              if (!imageUploaded) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Image is required to mark as resolved",
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 32),

            /// -------- UPDATE BUTTON --------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (status == "Resolved" && !imageUploaded)
                    ? null
                    : () {
                        _showConfirmDialog();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Update Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.update,
              color: status == "Resolved" ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 12),
            const Text(
              "Confirm Update",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to update the status to \"$status\"?",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _updateStatus();
            },
            child: Text(
              "Update",
              style: TextStyle(
                color: status == "Resolved" ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: status == "Resolved" ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 12),
            const Text(
              "Status Updated",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          "The complaint status has been updated to \"$status\" successfully.",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to detail screen
            },
            child: const Text(
              "OK",
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}