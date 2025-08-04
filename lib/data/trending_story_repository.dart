import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

class TrendingStoryRepository {
  final String _trendingStoriesApiUrl = '${Environment.backendUrl}/api/stories/trending';

  Future<List<dynamic>> fetchTrendingStories() async {
    try {
      final response = await http.get(Uri.parse(_trendingStoriesApiUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load trending stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
