import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:soma/core/widgets/stories/story_unlock_card.dart';
import 'package:soma/core/widgets/guest_registration_card.dart';
import 'package:soma/features/story_detail_page/viewmodels/story_detail_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/services/story_repository.dart';
import 'package:soma/core/services/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:soma/features/author_profile_page/views/author_profile_page.dart';
import 'package:soma/core/config/environment.dart';
import 'package:soma/core/widgets/show_toast.dart';

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
  bool _isDataLoaded = false; // New flag
  bool _hasUpvoted = false; // Track if the user has already upvoted
  int _upvotes = 0; // Initialize upvotes from story data

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client(); // Initialize http client

    _initializeDependencies().then((_) {
      // After dependencies are initialized, fetch data
      _initializeData();
    });

    _fetchStoryDetails();
  }

  Future<void> _initializeDependencies() async {
    _prefs = await SharedPreferences.getInstance(); // Await here
    _userRepository = UserRepository(prefs: _prefs, client: _httpClient);
    _storyRepository = StoryRepository(client: _httpClient);
    // _initializeData() will be called in .then() block of initState
  }

  Future<void> _initializeData() async {
    final String? token = _prefs.getString('jwt_token');
    if (token == null) {
      print('Error: No authentication token found.');
      setState(() {
        _isDataLoaded =
            true; // Set to true even if no token, to stop loading indicator
      });
      return;
    }
    await _fetchCurrentUserTokens(); // Await here
    await _checkStoryUnlockStatus(token); // Await here
    setState(() {
      _isDataLoaded = true; // Set to true after data is loaded
    });
  }

  Future<void> _fetchCurrentUserTokens() async {
    try {
      final userDetails = await _userRepository.getCurrentUserDetails();
      setState(() {
        _currentUserId = userDetails['_id'];
        _currentUserTokens =
            (userDetails['tokens'] as num?)?.toInt() ??
            0; // Fixed type conversion
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

    try {
      final token = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('jwt_token'),
      );
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      await _storyRepository.unlockStory(widget.story['_id'], token);

      // Fetch the full story details after unlocking
      final fullStoryDetails = await _storyRepository.fetchStoryById(
        widget.story['_id'],
        token,
      );

      setState(() {
        widget.story.addAll(fullStoryDetails);
        _isStoryUnlocked = true;
      });

      // Show success message
      showToast(context, 'Story unlocked successfully!', type: ToastType.success);
    } catch (e) {
      print('Error unlocking story: $e');
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

  Future<void> _handleUpvote() async {
    if (_hasUpvoted) {
      _showSnackBar('You have already upvoted this story.');
      return;
    }

    final String? token = _prefs.getString('jwt_token');
    if (token == null) {
      _showSnackBar('Authentication token not found. Please log in.');
      return;
    }

    final String storyId = widget.story['_id'];
    try {
      final response = await _httpClient.patch(
        Uri.parse('${Environment.backendUrl}/api/stories/$storyId/upvote'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasUpvoted = true;
          _upvotes += 1; // Increment upvotes
        });
        _showSnackBar(
          'Story upvoted successfully!',
          backgroundColor: Colors.green.shade200,
        );
      } else {
        _showSnackBar('Failed to upvote story: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('An error occurred while upvoting: $e');
    }
  }

  Future<void> _fetchStoryDetails() async {
    try {
      final token = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('jwt_token'),
      );
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final storyDetails = await _storyRepository.fetchStoryById(
        widget.story['_id'],
        token,
      );

      setState(() {
        widget.story.addAll(storyDetails);
        _isDataLoaded = true;
      });
    } catch (e) {
      print('Error fetching story details: $e');
      setState(() {
        _isDataLoaded = false;
      });
    }
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
              actions: [
                Row(
                  children: [
                    Text(
                      '$_upvotes',
                      style: const TextStyle(fontSize: 16),
                    ), // Display upvotes
                    IconButton(
                      icon: Icon(
                        _hasUpvoted
                            ? Icons.arrow_upward
                            : Icons.arrow_upward_outlined,
                        color: _hasUpvoted ? Colors.blue : Colors.black,
                      ),
                      onPressed: _handleUpvote,
                    ),
                  ],
                ),
              ],
            ),
            body: _isDataLoaded
                ? SingleChildScrollView(
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
                        Row(
                          // Wrap author and tags in a Row
                          children: [
                            GestureDetector(
                              onTap: () {
                                final String? authorId =
                                    widget.story['author']?['_id'];
                                if (authorId != null) {
                                  print(
                                    'Navigating to AuthorProfilePage with authorId: $authorId',
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AuthorProfilePage(authorId: authorId),
                                    ),
                                  );
                                } else {
                                  print(
                                    'Author ID is null. Cannot navigate to AuthorProfilePage.',
                                  );
                                }
                              },
                              child: Text(
                                'By $authorName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Space between author and tags
                            if (widget.story['tags'] != null &&
                                widget.story['tags'].isNotEmpty)
                              Expanded(
                                // Use Expanded to allow tags to wrap
                                child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 0.0,
                                  children: (widget.story['tags'] as List<dynamic>)
                                      .map((tag) {
                                        String tagName;
                                        if (tag is Map<String, dynamic>) {
                                          tagName = tag['name'] ?? '';
                                        } else if (tag is String) {
                                          tagName = tag;
                                        } else {
                                          tagName =
                                              ''; // Default or handle unexpected type
                                        }
                                        return Chip(
                                          label: Text(
                                            tagName,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFF333333,
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                          ],
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
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                      ),
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
                        if (isPremium) ...[
                          if (_currentUserId == null) // Guest user
                            GuestRegistrationCard(
                              onRegisterPressed: () {
                                // Navigate to registration/login page
                                Navigator.pushNamed(context, '/register');
                              },
                            )
                          else if (!_isStoryUnlocked && !isMyStory) ...[
                            if (_currentUserTokens < widget.story['tokenPrice'])
                              StoryUnlockCard(
                                cardType: UnlockCardType.topUp,
                                neededTokens: widget.story['tokenPrice'],
                                onButtonPressed: () {
                                  _handleTopUp();
                                },
                                isLoading: _isUnlocking,
                              )
                            else
                              StoryUnlockCard(
                                cardType: UnlockCardType.unlock,
                                neededTokens: widget.story['tokenPrice'],
                                onButtonPressed: () {
                                  _handleUnlockStory();
                                },
                                isLoading: _isUnlocking,
                              ),
                          ],
                        ],
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ), // Show loading indicator
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}
