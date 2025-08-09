import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/widgets/show_toast.dart';
import '../../../data/story_repository.dart';
import '../../../data/trending_story_repository.dart';

class HomePageViewModel extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository();
  final TrendingStoryRepository _trendingStoryRepository = TrendingStoryRepository();
  int _selectedIndex = 0;
  List<dynamic> _stories = [];
  List<dynamic> _trendingStories = [];
  String _errorMessage = '';
  bool _isLoading = true;
  String? _userRole; // Added to store user role

  int get selectedIndex => _selectedIndex;
  List<dynamic> get stories => _stories;
  List<dynamic> get trendingStories => _trendingStories;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get userRole => _userRole; // Getter for user role

  HomePageViewModel() {
    fetchStories();
  }

  void onItemTapped(int index, BuildContext context) async { // Added async
    final SharedPreferences prefs = await SharedPreferences.getInstance(); // Fetch prefs
    _userRole = prefs.getString('user_role'); // Update _userRole

    if (index == 2 && _userRole == 'reader') {
      showToast(context, 'Readers cannot upload stories. Please request a writer account.', isSuccess: false);
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Fetch user role from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('user_role'); // Assuming role is stored here

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