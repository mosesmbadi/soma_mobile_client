import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/features/landing_page/views/landing_page.dart';
import '../../../core/config/environment.dart';
import 'package:soma/data/user_repository.dart';
import 'package:soma/data/story_repository.dart';
import 'package:soma/data/trending_story_repository.dart';
import '../../../core/widgets/show_toast.dart';

const String apiUrl = '${Environment.backendUrl}/api/auth/me';

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
  String? get phoneNumber => _userData?['phone'];

  Future<String?> getAuthToken() async {
    return _prefs.getString('jwt_token');
  }

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

  Future<Map<String, dynamic>> requestWriterAccess() async {
    final String? token = _prefs.getString('jwt_token');
    if (token == null) {
      return {'success': false, 'message': 'No authentication token found. Please log in.'};
    }
    return await _userRepository.requestWriterAccess(token);
  }
  
  Future<void> fetchUserData() async {
    _errorMessage = '';
    notifyListeners();

    final String? token = _prefs.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
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
        print('User Data fetched: $_userData'); // Add this line
        if (_userData!['role'] == 'reader') {
          await _fetchRecentReads(token);
          if (_recentReads.isEmpty) {
            await _fetchTrendingStories();
          }
        } else if (_userData!['role'] == 'writer') {
          await _fetchMyStories(token);
          if (_myStories.isEmpty) {
            await _fetchTrendingStories();
          }
        }
      } else {
        _errorMessage = 'Failed to load user data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> _fetchRecentReads(String token) async {
    try {
      _recentReads = await _userRepository.fetchRecentReads(token);
    } catch (e) {
      print('Error fetching recent reads: $e');
      _errorMessage = 'Failed to load recent reads: $e';
    }
  }

  Future<void> _fetchMyStories(String token) async {
    try {
      _myStories = await _storyRepository.fetchMyStories(token);
    } catch (e) {
      print('Error fetching my stories: $e');
      _errorMessage = 'Failed to load my stories: $e';
    }
  }

  Future<void> _fetchTrendingStories() async {
    try {
      _trendingStories = await _trendingStoryRepository.fetchTrendingStories();
    } catch (e) {
      print('Error fetching trending stories: $e');
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

  Future<void> requestWithdrawal(double amount, BuildContext context) async {
    final String? token = await getAuthToken();
    if (token == null) {
      showToast(context, 'Authentication token not found. Please log in again.', type: ToastType.error);
      return;
    }

    final url = Uri.parse('${Environment.backendUrl}/api/users/withdrawal-request');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'amount_requested': amount,
        }),
      );

      final responseBody = jsonDecode(response.body);
      final bool success = responseBody['success'] ?? false;
      final String message = responseBody['message'] ?? 'An unknown error occurred.';

      if (success) {
        showToast(context, message, type: ToastType.success);
      } else {
        showToast(context, message, type: ToastType.error);
      }
    } catch (e) {
      showToast(context, 'Failed to connect to the server: $e', type: ToastType.error);
    }
  }

  Future<void> requestMpesaTopUp(double amount, String phoneNumber, BuildContext context) async {
    final String? token = await getAuthToken();
    if (token == null) {
      showToast(context, 'Authentication token not found. Please log in again.', type: ToastType.error);
      return;
    }

    final url = Uri.parse('${Environment.backendUrl}/api/mpesa/stkpush');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'amount': amount,
          'phoneNumber': phoneNumber,
        }),
      );

      final responseBody = jsonDecode(response.body);
      final bool success = responseBody['success'] ?? false;
      final String message = responseBody['message'] ?? 'An unknown error occurred.';

      if (success) {
        showToast(context, message, type: ToastType.success);
      } else {
        showToast(context, message, type: ToastType.error);
      }
    } catch (e) {
      showToast(context, 'Failed to connect to the server: $e', type: ToastType.error);
    }
  }
}
