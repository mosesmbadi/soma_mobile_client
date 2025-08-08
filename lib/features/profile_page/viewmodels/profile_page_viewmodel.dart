import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/features/landing_page/views/landing_page.dart';
import 'package:logger/logger.dart';
import '../../../core/config/environment.dart';
import 'package:soma/data/user_repository.dart';
import 'package:soma/data/story_repository.dart';
import 'package:soma/data/trending_story_repository.dart';

const String apiUrl = '${Environment.backendUrl}/api/auth/me';

final Logger logger = Logger();

class ProfilePageViewModel extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  List<dynamic> _recentReads = [];
  List<dynamic> _myStories = [];
  List<dynamic> _trendingStories = [];
  String _errorMessage = '';

  Map<String, dynamic>? get userData => _userData;
  List<dynamic> get recentReads => _recentReads;
  List<dynamic> get myStories => _myStories;
  List<dynamic> get trendingStories => _trendingStories;
  String get errorMessage => _errorMessage;

  final UserRepository _userRepository;
  final StoryRepository _storyRepository;
  final TrendingStoryRepository _trendingStoryRepository;
  final SharedPreferences _prefs;

  ProfilePageViewModel({required SharedPreferences prefs, http.Client? client})
      : _prefs = prefs,
        _userRepository = UserRepository(prefs: prefs, client: client),
        _storyRepository = StoryRepository(client: client),
        _trendingStoryRepository = TrendingStoryRepository(client: client) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    _errorMessage = '';
    notifyListeners();

    final String? token = _prefs.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
      logger.d('No authentication token found.');
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body) as Map<String, dynamic>;
        logger.d('User data fetched successfully: $_userData');
        if (_userData!['role'] == 'reader') {
          logger.d('User is a reader. Fetching recent reads.');
          await _fetchRecentReads(token);
          if (_recentReads.isEmpty) {
            logger.d('No recent reads found. Fetching trending stories.');
            await _fetchTrendingStories();
          }
        } else if (_userData!['role'] == 'writer') {
          logger.d('User is a writer. Fetching my stories.');
          await _fetchMyStories(token);
          if (_myStories.isEmpty) {
            logger.d('No stories found. Fetching trending stories.');
            await _fetchTrendingStories();
          }
        }
      } else {
        _errorMessage = 'Failed to load user data: ${response.statusCode}';
        logger.e('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      logger.e('An error occurred while fetching user data: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> _fetchRecentReads(String token) async {
    try {
      _recentReads = await _userRepository.fetchRecentReads(token);
      logger.d('Recent reads fetched successfully: $_recentReads');
    } catch (e) {
      logger.e('Error fetching recent reads: $e');
      _errorMessage = 'Failed to load recent reads: $e';
    }
  }

  Future<void> _fetchMyStories(String token) async {
    try {
      _myStories = await _storyRepository.fetchMyStories(token);
      logger.d('My stories fetched successfully: $_myStories');
    } catch (e) {
      logger.e('Error fetching my stories: $e');
      _errorMessage = 'Failed to load my stories: $e';
    }
  }

  Future<void> _fetchTrendingStories() async {
    try {
      _trendingStories = await _trendingStoryRepository.fetchTrendingStories();
      logger.d('Trending stories fetched successfully: $_trendingStories');
    } catch (e) {
      logger.e('Error fetching trending stories: $e');
      _errorMessage = 'Failed to load trending stories: $e';
    }
  }

  Future<void> logout(BuildContext context) async {
    await _prefs.remove('jwt_token');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void showTopUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Top Up Account'),
          content: const Text('Top Up functionality will be implemented here.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw Funds'),
          content: const Text(
            'Withdraw functionality will be implemented here.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
