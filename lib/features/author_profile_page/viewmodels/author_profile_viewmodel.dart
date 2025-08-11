import 'package:flutter/material.dart';
import 'package:soma/data/user_repository.dart';
import 'package:soma/data/story_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthorProfileViewModel extends ChangeNotifier {
  final String authorId;
  final UserRepository _userRepository;
  final StoryRepository _storyRepository;

  bool _isLoading = false;
  String _errorMessage = '';
  String _authorName = 'Unknown Author';
  List<Map<String, dynamic>> _authorStories = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get authorName => _authorName;
  List<Map<String, dynamic>> get authorStories => _authorStories;

  AuthorProfileViewModel({
    required this.authorId,
    required SharedPreferences prefs,
    required http.Client client,
  })  : _userRepository = UserRepository(prefs: prefs, client: client),
        _storyRepository = StoryRepository(client: client) {
    _fetchAuthorData();
  }

  // Synchronous getter for SharedPreferences, assuming it's already initialized elsewhere
  // This is a simplification; in a real app, you'd likely pass SharedPreferences
  // or ensure it's initialized asynchronously and then passed.
  static SharedPreferences _getPrefsSync() {
    // This is a placeholder. In a real app, you'd use a proper dependency injection
    // or ensure SharedPreferences.getInstance() has been called and awaited
    // before this ViewModel is instantiated.
    // For now, we'll just return a dummy or assume it's globally accessible.
    // This might cause issues if SharedPreferences is not ready.
    return throw Exception("SharedPreferences not initialized synchronously.");
  }

  Future<void> _fetchAuthorData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Fetch author details
      final authorDetails = await _userRepository.getUserById(authorId);
      _authorName = authorDetails['name'] ?? 'Unknown Author';

      // Fetch stories by this author
      final stories = await _storyRepository.getStoriesByAuthor(authorId);
      _authorStories = List<Map<String, dynamic>>.from(stories);

    } catch (e) {
      _errorMessage = 'Failed to load author data: $e';
      print('Error fetching author data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Dispose of any resources if necessary
    super.dispose();
  }
}
