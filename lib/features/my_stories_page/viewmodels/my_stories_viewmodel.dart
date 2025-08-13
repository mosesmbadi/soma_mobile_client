import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/story_repository.dart';

class MyStoriesViewModel extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository();
  List<dynamic> _myStories = [];
  String _errorMessage = '';
  bool _isLoading = true;
  bool _disposed = false;

  List<dynamic> get myStories => _myStories;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  MyStoriesViewModel() {
    fetchMyStories();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> fetchMyStories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final fetchedStories = await _storyRepository.fetchMyStories(token);
      for (var story in fetchedStories) {
        print('MyStoriesViewModel - Story ID: ${story['_id']}, Thumbnail URL: ${story['thumbnailUrl']}');
      }
      _myStories = fetchedStories;
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
