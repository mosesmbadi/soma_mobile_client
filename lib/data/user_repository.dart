import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/environment.dart';

class UserRepository {
  final http.Client _client;
  final SharedPreferences _prefs;
  final String _meApiUrl = '${Environment.backendUrl}/api/auth/me';

  UserRepository({http.Client? client, required SharedPreferences prefs})
      : _client = client ?? http.Client(),
        _prefs = prefs;

  Future<Map<String, dynamic>> getCurrentUserDetails() async {
    final String? token = _prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('No authentication token found.');
    }

    try {
      final response = await _client.get(
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

  Future<List<dynamic>> fetchRecentReads(String token) async {
    final String _unlockedStoriesApiUrl = '${Environment.backendUrl}/api/stories/user/unlocked';
    try {
      final response = await _client.get(
        Uri.parse(_unlockedStoriesApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recent reads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching recent reads: $e');
    }
  }
}