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

  // from wt token
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


Future<Map<String, dynamic>> requestWriterAccess(String token) async {
  try {
    final uri = Uri.parse(
      '${Environment.backendUrl}/api/users/writer-request',
    );
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'User-Agent': 'soma_mobile_client',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseBody = jsonDecode(response.body);
    final bool success = response.statusCode == 200 || response.statusCode == 201;
    final String message = responseBody['message'] ?? responseBody['error'] ?? (success ? 'Request successful' : 'Failed to send request.');
    return {'success': success, 'message': message};
  } catch (e) {
    // Log the error to understand what's happening
    print('Error making writer access request: $e');
    return {'success': false, 'message': 'An error occurred.'};
  }
}

  Future<List<dynamic>> fetchRecentReads(String token) async {
    final String _unlockedStoriesApiUrl =
        '${Environment.backendUrl}/api/stories/user/unlocked';
    try {
      final response = await _client.get(
        Uri.parse(_unlockedStoriesApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load recent reads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching recent reads: $e');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final String userApiUrl = '${Environment.backendUrl}/api/users/$userId';
    try {
      final response = await _client.get(Uri.parse(userApiUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user details for ID $userId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching user details for ID $userId: $e');
    }
  }
}

