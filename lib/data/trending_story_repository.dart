import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

class TrendingStoryRepository {
  final http.Client _client;
  final String _trendingStoriesApiUrl = '${Environment.backendUrl}/api/stories/trending';

  TrendingStoryRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<dynamic>> fetchTrendingStories() async {
    try {
      final response = await _client.get(Uri.parse(_trendingStoriesApiUrl));

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
