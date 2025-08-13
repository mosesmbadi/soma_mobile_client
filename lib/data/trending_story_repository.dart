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

  Future<List<Map<String, dynamic>>> fetchTrendingStories() async {
    try {
      final response = await _client.get(Uri.parse(_trendingStoriesApiUrl));

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          final List<Map<String, dynamic>> trendingStories = [];
          for (var item in decodedData) {
            if (item is Map<String, dynamic>) {
              trendingStories.add(item);
            } else {
              print('Warning: Expected Map<String, dynamic>, but got ${item.runtimeType}: $item');
            }
          }
          return trendingStories;
        } else {
          throw Exception('Expected a list from API, but got ${decodedData.runtimeType}');
        }
      } else {
        throw Exception('Failed to load trending stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
