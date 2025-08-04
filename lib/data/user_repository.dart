import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/environment.dart';

class UserRepository {
  final String _meApiUrl = '${Environment.backendUrl}/api/auth/me';

  Future<Map<String, dynamic>> getCurrentUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('No authentication token found.');
    }

    try {
      final response = await http.get(
        Uri.parse(_meApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching user details: $e');
    }
  }
}
