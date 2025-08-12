// lib/core/utils/story_read_tracker.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:soma/core/config/environment.dart';
import 'package:flutter/foundation.dart';

class StoryReadTracker {
  static Future<void> markAsRead(String storyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      debugPrint('User not logged in; cannot update story read count.');
      return;
    }

    final String apiUrl = '${Environment.backendUrl}/api/stories/$storyId/read';
    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Story read successfully marked for $storyId');
      } else {
        debugPrint('Failed to mark as read: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }
}
