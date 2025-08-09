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
import 'package:soma/core/widgets/show_toast.dart';
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
        _trendingStoryRepository = TrendingStoryRepository(client: client);

  Future<void> fetchUserData(BuildContext context) async {
    _errorMessage = '';
    notifyListeners();

    final String? token = _prefs.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
      logger.d('No authentication token found.');
      notifyListeners();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (_) => false,
        );
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body) as Map<String, dynamic>;

        if (_userData!['role'] != null) {
          _prefs.setString('user_role', _userData!['role']);
        }

        logger.d('User data fetched successfully: $_userData');

        if (_userData!['role'] == 'reader') {
          await _fetchRecentReads(token);
          if (_recentReads.isEmpty) await _fetchTrendingStories();
        } else if (_userData!['role'] == 'writer') {
          await _fetchMyStories(token);
          if (_myStories.isEmpty) await _fetchTrendingStories();
        }
      } else {
        _errorMessage = 'Failed to load user data: ${response.statusCode}';
        logger.e(_errorMessage);
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      logger.e(_errorMessage);
    } finally {
      notifyListeners();
    }
  }

  Future<void> _fetchRecentReads(String token) async {
    try {
      _recentReads = await _userRepository.fetchRecentReads(token);
      logger.d('Recent reads fetched: $_recentReads');
    } catch (e) {
      _errorMessage = 'Failed to load recent reads: $e';
      logger.e(_errorMessage);
    }
  }

  Future<void> _fetchMyStories(String token) async {
    try {
      _myStories = await _storyRepository.fetchMyStories(token);
      logger.d('My stories fetched: $_myStories');
    } catch (e) {
      _errorMessage = 'Failed to load my stories: $e';
      logger.e(_errorMessage);
    }
  }

  Future<void> _fetchTrendingStories() async {
    try {
      _trendingStories = await _trendingStoryRepository.fetchTrendingStories();
      logger.d('Trending stories fetched: $_trendingStories');
    } catch (e) {
      _errorMessage = 'Failed to load trending stories: $e';
      logger.e(_errorMessage);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _prefs.remove('jwt_token');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (_) => false,
      );
    }
  }

  void showTopUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Top Up Account'),
        content: Text('Top Up functionality will be implemented here.'),
      ),
    );
  }

  void showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Withdraw Funds'),
        content: Text('Withdraw functionality will be implemented here.'),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadProfilePhoto(BuildContext context) async {
    _errorMessage = '';
    notifyListeners();

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile == null) return;

      final String? token = _prefs.getString('jwt_token');
      if (token == null) {
        showToast(context, 'Please log in.', isSuccess: false);
        return;
      }

      final File imageFile = File(croppedFile.path);
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Environment.backendUrl}/api/users/profile/photo'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
            await http.MultipartFile.fromPath('profilePhoto', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        _userData?['profilePhotoUrl'] = data['profilePhotoUrl'];
        showToast(context, 'Profile photo updated!', isSuccess: true);
      } else {
        showToast(
          context,
          'Failed to upload photo (${response.statusCode})',
          isSuccess: false,
        );
      }
    } catch (e) {
      showToast(context, 'Upload failed: $e', isSuccess: false);
    } finally {
      notifyListeners();
    }
  }

  Future<void> pickAndUploadBannerPhoto(BuildContext context) async {
    _errorMessage = '';
    notifyListeners();

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Banner Photo',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
          ),
          IOSUiSettings(
            title: 'Crop Banner Photo',
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
          ),
        ],
      );

      if (croppedFile == null) return;

      final String? token = _prefs.getString('jwt_token');
      if (token == null) {
        showToast(context, 'Please log in.', isSuccess: false);
        return;
      }

      final File imageFile = File(croppedFile.path);
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Environment.backendUrl}/api/users/banner/photo'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
            await http.MultipartFile.fromPath('bannerPhoto', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        _userData?['bannerPhotoUrl'] = data['bannerPhotoUrl'];
        showToast(context, 'Banner photo updated!', isSuccess: true);
      } else {
        showToast(
          context,
          'Failed to upload banner (${response.statusCode})',
          isSuccess: false,
        );
      }
    } catch (e) {
      showToast(context, 'Upload failed: $e', isSuccess: false);
    } finally {
      notifyListeners();
    }
  }

  Future<void> requestWriterAccount(BuildContext context) async {
    _errorMessage = '';
    notifyListeners();

    final String? token = _prefs.getString('jwt_token');

    if (token == null) {
      showToast(context, 'Please log in.', isSuccess: false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Environment.backendUrl}/api/users/writer-request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showToast(
          context,
          'Writer account request sent successfully!',
          isSuccess: true,
        );
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Failed to send writer account request.';
        showToast(context, message, isSuccess: false);
      }
    } catch (e) {
      showToast(context, 'Request failed: $e', isSuccess: false);
    } finally {
      notifyListeners();
    }
  }
}
