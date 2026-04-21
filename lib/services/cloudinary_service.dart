import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // 🔑 APNI VALUES YAHAN DALO (Cloudinary dashboard se)
  static const String cloudName = "dkrqwud4r";  // 👈 Apna cloud name
  static const String uploadPreset = "city_care_preset"; // 👈 Upload preset name

  // 🖼️ Image picker function
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,  // Chhoti image, fast upload
      maxHeight: 500,
      imageQuality: 80, // Quality thodi kam, but fast
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // ☁️ Cloudinary par upload karo
  static Future<String?> uploadImage(File imageFile) async {
    try {
      print('📤 Uploading to Cloudinary...');
      
      // Cloudinary API URL
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
      );

      // Multipart request banao
      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path)
        );

      // Request send karo
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        
        // 🔥 YEH LO URL - Firestore mein save karna
        String imageUrl = jsonResponse['secure_url'];
        print('✅ Upload successful! URL: $imageUrl');
        
        return imageUrl;
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  // 📸 Ek saath pick aur upload
  static Future<String?> pickAndUploadImage() async {
    // Pick image
    final imageFile = await pickImage();
    if (imageFile == null) return null;

    // Upload to Cloudinary
    final imageUrl = await uploadImage(imageFile);
    return imageUrl;
  }
}