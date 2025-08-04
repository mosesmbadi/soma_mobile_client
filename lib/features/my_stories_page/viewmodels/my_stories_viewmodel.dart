import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/story_repository.dart';

class MyStoriesViewModel extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository();
  List<dynamic> _myStories = [];
  String _errorMessage = '';
  bool _isLoading = true;

  List<dynamic> get myStories => _myStories;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  MyStoriesViewModel() {
    fetchMyStories();
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
      _myStories = await _storyRepository.fetchMyStories(token);
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
