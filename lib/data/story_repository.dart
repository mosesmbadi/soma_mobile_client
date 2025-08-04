import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

class StoryRepository {
  final String _storiesApiUrl = '${Environment.backendUrl}/api/stories';
  final String _myStoriesApiUrl = '${Environment.backendUrl}/api/stories/me';

  Future<List<dynamic>> fetchStories() async {
    try {
      final response = await http.get(Uri.parse(_storiesApiUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<List<dynamic>> fetchMyStories(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_myStoriesApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load your stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
