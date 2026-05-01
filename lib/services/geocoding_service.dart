import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _apiKey = "YOUR_API_KEY_HERE";  

  // Coordinates se address dhundho
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'latlng=$lat,$lng&key=$_apiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Pehla result lo (sabse accurate)
          String fullAddress = data['results'][0]['formatted_address'];
          return fullAddress;
        }
      }
      return 'Unknown location';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Unknown location';
    }
  }

  // Short address dhundho (Model Town jaise)
  static Future<String> getShortAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'latlng=$lat,$lng&key=$_apiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Different address components se best guess lo
          var components = data['results'][0]['address_components'];
          var formattedAddress = data['results'][0]['formatted_address'];
          
          // Koshish karo ke locality ya neighborhood mile
          String? locality;
          String? subLocality;
          String? neighborhood;
          String? adminArea;
          
          for (var component in components) {
            if (component['types'].contains('locality')) {
              locality = component['long_name'];
            } else if (component['types'].contains('sublocality') || 
                       component['types'].contains('sublocality_level_1')) {
              subLocality = component['long_name'];
            } else if (component['types'].contains('neighborhood')) {
              neighborhood = component['long_name'];
            } else if (component['types'].contains('administrative_area_level_2')) {
              adminArea = component['long_name']; // City level
            }
          }
          
          // Short address banaiye
          if (subLocality != null && locality != null) {
            return '$subLocality, $locality';
          } else if (neighborhood != null && locality != null) {
            return '$neighborhood, $locality';
          } else if (locality != null) {
            return locality;
          } else if (adminArea != null) {
            return adminArea;
          } else {
            // Agar kuch na mile to formatted address ka pehla part lein
            List<String> parts = formattedAddress.split(',');
            return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : parts[0];
          }
        }
      }
      return 'Unknown location';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Unknown location';
    }
  }
}