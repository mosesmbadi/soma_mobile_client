import 'package:flutter/material.dart';
import '../../../data/story_repository.dart';
import '../../../data/trending_story_repository.dart';

class HomePageViewModel extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository();
  final TrendingStoryRepository _trendingStoryRepository = TrendingStoryRepository();
  int _selectedIndex = 0;
  List<dynamic> _stories = [];
  List<Map<String, dynamic>> _trendingStories = [];
  String _errorMessage = '';
  bool _isLoading = true;

  int get selectedIndex => _selectedIndex;
  List<dynamic> get stories => _stories;
  List<Map<String, dynamic>> get trendingStories => _trendingStories;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  HomePageViewModel() {
    fetchStories();
  }

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _stories = await _storyRepository.fetchStories();
      _trendingStories = await _trendingStoryRepository.fetchTrendingStories();
      
      
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}