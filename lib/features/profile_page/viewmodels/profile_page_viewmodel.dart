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
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

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
        // Store user role in SharedPreferences
        if (_userData!['role'] != null) {
          _prefs.setString('user_role', _userData!['role']);
        }
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

  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadProfilePhoto() async {
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Pick Image
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        logger.d('User cancelled image picking.');
        return; // User cancelled
      }

      // 2. Crop Image (Optional but Recommended)
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            aspectRatioLockDimensionSwapEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile == null) {
        logger.d('User cancelled image cropping.');
        return; // User cancelled cropping
      }

      // 3. Upload Image to Backend
      final String? token = _prefs.getString('jwt_token');
      if (token == null) {
        _errorMessage = 'No authentication token found. Please log in.';
        logger.e('Attempted to upload photo without token.');
        notifyListeners();
        return;
      }

      final File imageFile = File(croppedFile.path);
      // Assuming your backend endpoint for profile photo upload is /api/users/profile/photo
      final uri = Uri.parse('${Environment.backendUrl}/api/users/profile/photo');
      final request = http.MultipartRequest('PUT', uri) // Or POST, depending on your backend
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('profilePhoto', imageFile.path)); // 'profilePhoto' is the field name your backend expects

      logger.d('Uploading profile photo...');
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        // The backend now sends back the S3 URL, update local data
        _userData?['profilePhotoUrl'] = data['profilePhotoUrl'];
        logger.d('Profile photo uploaded successfully. New URL: ${_userData?['profilePhotoUrl']}');
        _errorMessage = ''; // Clear any previous error messages
      } else {
        final errorBody = await response.stream.bytesToString();
        _errorMessage = 'Failed to upload photo: ${response.statusCode} - $errorBody';
        logger.e('Failed to upload profile photo: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      _errorMessage = 'An error occurred during photo upload: $e';
      logger.e('Exception during photo upload: $e');
    } finally {
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  Future<void> pickAndUploadBannerPhoto() async {
    _errorMessage = '';
    notifyListeners();

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        logger.d('User cancelled banner image picking.');
        return;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Banner Photo',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Banner Photo',
            aspectRatioLockEnabled: true,
            aspectRatioLockDimensionSwapEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile == null) {
        logger.d('User cancelled banner image cropping.');
        return;
      }

      final String? token = _prefs.getString('jwt_token');
      if (token == null) {
        _errorMessage = 'No authentication token found. Please log in.';
        logger.e('Attempted to upload banner photo without token.');
        notifyListeners();
        return;
      }

      final File imageFile = File(croppedFile.path);
      final uri = Uri.parse('${Environment.backendUrl}/api/users/banner/photo'); // New backend endpoint for banner
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('bannerPhoto', imageFile.path)); // 'bannerPhoto' is the field name your backend expects

      logger.d('Uploading banner photo...');
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        _userData?['bannerPhotoUrl'] = data['bannerPhotoUrl']; // Update local data
        logger.d('Banner photo uploaded successfully. New URL: ${_userData?['bannerPhotoUrl']}');
        _errorMessage = '';
      } else {
        final errorBody = await response.stream.bytesToString();
        _errorMessage = 'Failed to upload banner photo: ${response.statusCode} - $errorBody';
        logger.e('Failed to upload banner photo: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      _errorMessage = 'An error occurred during banner photo upload: $e';
      logger.e('Exception during banner photo upload: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> requestWriterAccount(BuildContext context) async {
    _errorMessage = '';
    notifyListeners();

    final String? token = _prefs.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
      logger.e('Attempted to request writer account without token.');
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Environment.backendUrl}/api/users/writer-request'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Writer account request sent successfully!')),
        );
        logger.d('Writer account request sent successfully.');
      } else {
        final errorBody = jsonDecode(response.body);
        _errorMessage = errorBody['message'] ?? 'Failed to send writer account request.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
        logger.e('Failed to send writer account request: ${response.statusCode} - $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'An error occurred while requesting writer account: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
      logger.e('Exception during writer account request: $e');
    } finally {
      notifyListeners();
    }
  }
}
