import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:soma/core/widgets/story_unlock_card.dart';
import 'package:soma/features/story_detail_page/viewmodels/story_detail_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/data/story_repository.dart';
import 'package:soma/data/user_repository.dart';
import 'package:http/http.dart' as http;

class StoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({super.key, required this.story});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late final StoryRepository _storyRepository;
  late final UserRepository _userRepository;
  late final SharedPreferences _prefs;
  late final http.Client _httpClient;

  String? _currentUserId;
  bool _isStoryUnlocked = false;
  int _currentUserTokens = 0;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client(); // Initialize http client
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    _prefs = await SharedPreferences.getInstance();
    _userRepository = UserRepository(prefs: _prefs, client: _httpClient);
    _storyRepository = StoryRepository(client: _httpClient);
    _initializeData();
  }

  Future<void> _initializeData() async {
    final String? token = _prefs.getString('jwt_token');
    if (token == null) {
      print('Error: No authentication token found.');
      return;
    }
    _fetchCurrentUserTokens();
    _checkStoryUnlockStatus(token);
  }

  Future<void> _fetchCurrentUserTokens() async {
    try {
      final userDetails = await _userRepository.getCurrentUserDetails();
      setState(() {
        _currentUserId = userDetails['_id'];
        _currentUserTokens = userDetails['tokens'] ?? 0;
      });
    } catch (e) {
      print('Error fetching current user details: $e');
    }
  }

  Future<void> _checkStoryUnlockStatus(String token) async {
    try {
      final unlocked = await _storyRepository.isStoryUnlocked(
        widget.story['_id'],
        token,
      );
      setState(() {
        _isStoryUnlocked = unlocked;
      });
    } catch (e) {
      print('Error checking story unlock status: $e');
    }
  }

  void _showSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleUnlockStory() async {
    setState(() {
      _isUnlocking = true;
    });
    final String? token = _prefs.getString('jwt_token');
    if (token == null) {
      _showSnackBar('Authentication token not found. Please log in.');
      setState(() {
        _isUnlocking = false;
      });
      return;
    }

    final String storyId = widget.story['_id'];
    try {
      await _storyRepository.unlockStory(storyId, token);
      _showSnackBar(
        'Story unlocked successfully!',
        backgroundColor: Colors.green.shade200,
      );
      setState(() {
        _isStoryUnlocked = true;
      });
      _fetchCurrentUserTokens();
    } catch (e) {
      _showSnackBar('Failed to unlock story: $e');
    } finally {
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  void _handleTopUp() {
    _showSnackBar('Navigating to top-up options...');
    print('Attempting to top up!');
  }

  @override
  Widget build(BuildContext context) {
    final String storySlug = widget.story['slug'] ?? '';
    final int estimatedTime = widget.story['estimatedTime'] ?? 30;
    final bool isPremium = widget.story['is_premium'] == true;
    final bool isMyStory =
        _currentUserId != null &&
        widget.story['author']?['_id'] == _currentUserId;

    return ChangeNotifierProvider(
      create: (_) =>
          StoryDetailViewModel(storySlug, widget.story['_id'], estimatedTime),
      child: Consumer<StoryDetailViewModel>(
        builder: (context, viewModel, child) {
          final String title = widget.story['title'] ?? 'No Title';
          final String authorName =
              widget.story['author']?['name'] ?? 'Unknown Author';
          final String? thumbnailUrl = widget.story['thumbnailUrl'];

          final contentJson = jsonDecode(widget.story['content'] ?? '[]');
          final document = Document.fromJson(contentJson);

          // Ensure the document ends with a newline, as required by flutter_quill
          if (!document.toPlainText().endsWith('\n')) {
            document.insert(document.length, '\n');
          }

          final fullDelta = document.toDelta();

          final quillController = QuillController(
            document: Document.fromDelta(fullDelta),
            selection: const TextSelection.collapsed(offset: 0),
          );

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 232, 186, 255),
            ),
            body: SingleChildScrollView(
              controller: viewModel.scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By $authorName',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                        ),
                      ),
                    ),

                  // Display full story content
                  QuillEditor(
                    controller: quillController,
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                    config: QuillEditorConfig(
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ), // Add some space before the premium card
                  // Premium gate at the end of the story
                  if (isPremium && !_isStoryUnlocked && !isMyStory) ...[
                    if (_currentUserTokens < 1)
                      StoryUnlockCard(
                        cardType: UnlockCardType.topUp,
                        onButtonPressed: _handleTopUp,
                        isLoading: _isUnlocking,
                      )
                    else
                      StoryUnlockCard(
                        cardType: UnlockCardType.unlock,
                        onButtonPressed: _handleUnlockStory,
                        isLoading: _isUnlocking,
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
