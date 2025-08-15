import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/config/environment.dart';

class ImageUploadService {
  static Future<String> uploadImage(File imageFile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final uri = Uri.parse('${Environment.backendUrl}/api/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final imageUrl = responseData.body; // backend returns JSON with imageUrl
      // Parse the JSON response to extract the imageUrl
      final Map<String, dynamic> jsonResponse = jsonDecode(imageUrl);
      return jsonResponse['imageUrl'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}