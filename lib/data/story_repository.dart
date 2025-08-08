import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

class StoryRepository {
  final http.Client _client;
  final String _storiesApiUrl = '${Environment.backendUrl}/api/stories';

  StoryRepository({http.Client? client}) : _client = client ?? http.Client();
  // fetch list of stories for the loggedin user
  final String _myStoriesApiUrl = '${Environment.backendUrl}/api/stories/my-stories';
  // fetch list of unlocked stories for the loggedin user
  final String _unlockedStoriesApiUrl = '${Environment.backendUrl}/api/stories/user/unlocked';

  Future<List<dynamic>> fetchStories() async {
    try {
      final response = await _client.get(Uri.parse(_storiesApiUrl));

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
      final response = await _client.get(
        Uri.parse(_myStoriesApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load your stories: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> updateStoryReadCount(String storyId, String token) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_storiesApiUrl/$storyId/read'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update read count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating read count: $e');
    }
  }

  Future<List<String>> fetchUnlockedStoryIds(String token) async {
    try {
      final response = await _client.get(
        Uri.parse(_unlockedStoriesApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> unlockedStoriesJson = jsonDecode(response.body);
        return unlockedStoriesJson.map((story) => story['_id'] as String).toList();
      } else {
        throw Exception('Failed to load unlocked stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching unlocked stories: $e');
    }
  }

  Future<bool> isStoryUnlocked(String storyId, String token) async {
    try {
      final List<String> unlockedStoryIds = await fetchUnlockedStoryIds(token);
      return unlockedStoryIds.contains(storyId);
    } catch (e) {
      print('Error checking if story is unlocked: $e');
      return false; // Assume not unlocked on error
    }
  }

  Future<void> unlockStory(String storyId, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('$_storiesApiUrl/$storyId/unlock'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({}), // Send an empty JSON object
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unlock story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error unlocking story: $e');
    }
  }
}
