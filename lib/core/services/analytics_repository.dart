import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

class AnalyticsRepository {
  final http.Client _client;
  final String _analyticsApiUrl =
      '${Environment.backendUrl}/api/stories/analytics';

  AnalyticsRepository({http.Client? client})
    : _client = client ?? http.Client();

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? '';
  }

  Future<Map<String, dynamic>> fetchUserAnalytics() async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('$_analyticsApiUrl/user'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to fetch user analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while fetching user analytics: $e');
    }
  }

  Future<List<dynamic>> fetchEarningsPerMonth(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$_analyticsApiUrl/earnings'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to fetch earnings per month: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'An error occurred while fetching earnings per month: $e',
      );
    }
  }

  Future<List<dynamic>> fetchTopPerformingStories(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$_analyticsApiUrl/top-performing'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to fetch top-performing stories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'An error occurred while fetching top-performing stories: $e',
      );
    }
  }

  Future<List<dynamic>> fetchMostReadStories(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$_analyticsApiUrl/most-read'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to fetch most-read stories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while fetching most-read stories: $e');
    }
  }

  Future<List<dynamic>> fetchMostUpvotedStories(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$_analyticsApiUrl/most-upvoted'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to fetch most-upvoted stories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'An error occurred while fetching most-upvoted stories: $e',
      );
    }
  }
}
