import 'package:flutter/material.dart';
import '../../../data/story_repository.dart';

class GuestStoriesViewModel extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository();
  List<dynamic> _stories = [];
  String _errorMessage = '';
  bool _isLoading = true;
  final Set<String> _openedStoryIds = {};

  List<dynamic> get stories => _stories;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Set<String> get openedStoryIds => _openedStoryIds;

  GuestStoriesViewModel() {
    fetchStories();
  }

  void markStoryAsOpened(String storyId) {
    _openedStoryIds.add(storyId);
    notifyListeners();
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _stories = await _storyRepository.fetchStories();
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
