import 'package:flutter/material.dart';
import 'package:soma/core/services/user_repository.dart';
import 'package:soma/core/services/story_repository.dart';
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

  static SharedPreferences _getPrefsSync() {
    // TODO: This might cause issues if SharedPreferences is not ready.
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
