import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/services/image_upload_service.dart';
import '../../../core/config/environment.dart';

const String apiUrl = '${Environment.backendUrl}/api/stories';
const String tagsApiUrl = '${Environment.backendUrl}/api/stories/tags';

class AddStoryViewModel extends ChangeNotifier {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String _errorMessage = '';
  bool _isLoading = false;

  String? _thumbnailUrl;

  List<dynamic> _availableTags = [];
  List<String> _selectedTagIds = [];
  String _tagsErrorMessage = '';

  String? _publishedStoryUrl;
  bool _showShareOptions = false;

  // Getters
  QuillController get controller => _controller;
  TextEditingController get titleController => _titleController;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  FocusNode get focusNode => _focusNode;
  ScrollController get scrollController => _scrollController;
  String? get thumbnailUrl => _thumbnailUrl;
  List<dynamic> get availableTags => _availableTags;
  List<String> get selectedTagIds => _selectedTagIds;
  String get tagsErrorMessage => _tagsErrorMessage;

  String? get publishedStoryUrl => _publishedStoryUrl;
  bool get showShareOptions => _showShareOptions;

  final http.Client _httpClient;
  final SharedPreferences _sharedPreferences; // Make it final

  AddStoryViewModel({http.Client? httpClient, required SharedPreferences sharedPreferences}) // Require SharedPreferences
      : _httpClient = httpClient ?? http.Client(),
        _sharedPreferences = sharedPreferences { // Initialize directly
    _loadSavedStory();
    _fetchTags();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void displayShareOptions() { // Renamed method
    _showShareOptions = true;
    notifyListeners();
  }

  void hideShareOptions() {
    _showShareOptions = false;
    _publishedStoryUrl = null; // Clear URL when hiding
    notifyListeners();
  }

  Future<void> _fetchTags() async {
    print('Entering _fetchTags()');
    _isLoading = true;
    _tagsErrorMessage = '';
    notifyListeners();

    try {
      final String? token = _sharedPreferences.getString('jwt_token');
      print('Fetching tags. Token: $token, API URL: $tagsApiUrl');

      if (token == null) {
        _tagsErrorMessage = 'Authentication token not found. Cannot fetch tags.';
        _isLoading = false;
        notifyListeners();
        print('Tags fetch failed: Authentication token not found.');
        return;
      }

      final response = await _httpClient.get(
        Uri.parse(tagsApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Tags API response status: ${response.statusCode}');
      print('Tags API response body: ${response.body}');

      if (response.statusCode == 200) {
        _availableTags = jsonDecode(response.body);
        print('Available tags: $_availableTags');
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _tagsErrorMessage = errorData['message'] ?? 'Failed to fetch tags.';
        print('Tags fetch failed: $_tagsErrorMessage');
      }
    } catch (e) {
      _tagsErrorMessage = 'An error occurred while fetching tags: $e';
      print('Tags fetch failed with exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTagSelection(String tagId) {
    if (_selectedTagIds.contains(tagId)) {
      _selectedTagIds.remove(tagId);
    } else {
      if (_selectedTagIds.length < 3) {
        _selectedTagIds.add(tagId);
      } else {
        _tagsErrorMessage = 'You can select a maximum of 3 tags.';
      }
    }
    notifyListeners();
  }

  Future<void> _loadSavedStory() async {
    final String? savedTitle = _sharedPreferences.getString('draft_story_title');
    final String? savedContent = _sharedPreferences.getString('draft_story_content');

    if (savedTitle != null && savedContent != null) {
      _titleController.text = savedTitle;
      try {
        _controller.document = Document.fromJson(jsonDecode(savedContent));
      } catch (e) {
        _controller.document = Document();
      }
    }
    notifyListeners();
  }

  Future<void> saveStoryLocally(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _sharedPreferences.setString('draft_story_title', _titleController.text);
      await _sharedPreferences.setString(
        'draft_story_content',
        jsonEncode(_controller.document.toDelta().toJson()),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story saved as draft locally!')),
      );
    } catch (e) {
      _errorMessage = 'Failed to save story locally: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> publishStory(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final String title = _titleController.text.trim();
    final String content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty || _controller.document.toPlainText().trim().isEmpty) {
      _errorMessage = 'Title and content cannot be empty.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_selectedTagIds.isEmpty || _selectedTagIds.length > 3) {
      _errorMessage = 'Please select between 1 and 3 tags.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final String? token = _sharedPreferences.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    List<Map<String, dynamic>> docOperations = _controller.document.toDelta().toJson();
    List<Map<String, dynamic>> modifiedDocOperations = [];

    for (var op in docOperations) {
      if (op['insert'] is Map && op['insert'].containsKey('image')) {
        final imageUrl = op['insert']['image'];

        if (_thumbnailUrl == null) { // This is the first image found
          _thumbnailUrl = imageUrl;
          // Do NOT add this operation to modifiedDocOperations, effectively removing it from the content
          continue; // Skip to the next operation
        }
      }
      modifiedDocOperations.add(op); // Add all other operations
    }

    // If no image was found in the document, thumbnailUrl remains null.
    // In this case, the content will be the original document content.
    // If an image was found and removed, the content will be the modified document.
    final String contentToSend = jsonEncode(modifiedDocOperations);

    try {
      final response = await _httpClient.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'content': contentToSend,
          'thumbnailUrl': thumbnailUrl,
          'tags': _selectedTagIds, 
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _publishedStoryUrl = responseData['storyUrl']; // Assuming backend returns 'storyUrl'
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story published successfully!')),
        );
        _titleController.clear();
        _controller.clear();
        _selectedTagIds.clear();
        await _sharedPreferences.remove('draft_story_title');
        await _sharedPreferences.remove('draft_story_content');
        displayShareOptions(); // Show share options after success
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to publish story.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Formatting Controls
  void toggleBold() {
    _controller.formatSelection(Attribute.bold);
  }

  void toggleItalic() {
    _controller.formatSelection(Attribute.italic);
  }

  void toggleUnderline() {
    _controller.formatSelection(Attribute.underline);
  }

  void toggleStrikeThrough() {
    _controller.formatSelection(Attribute.strikeThrough);
  }

  void toggleLink() {
    _controller.formatSelection(Attribute.link);
  }

  void clearFormatting() {
    _controller.formatSelection(Attribute.clone(Attribute.background, null));
    _controller.formatSelection(Attribute.clone(Attribute.color, null));
    _controller.formatSelection(Attribute.clone(Attribute.font, null));
    _controller.formatSelection(Attribute.clone(Attribute.size, null));
    _controller.formatSelection(Attribute.clone(Attribute.bold, null));
    _controller.formatSelection(Attribute.clone(Attribute.italic, null));
    _controller.formatSelection(Attribute.clone(Attribute.underline, null));
    _controller.formatSelection(Attribute.clone(Attribute.strikeThrough, null));
    _controller.formatSelection(Attribute.clone(Attribute.align, null));
    _controller.formatSelection(Attribute.clone(Attribute.direction, null));
    _controller.formatSelection(Attribute.clone(Attribute.list, null));
    _controller.formatSelection(Attribute.clone(Attribute.codeBlock, null));
    _controller.formatSelection(Attribute.clone(Attribute.blockQuote, null));
    _controller.formatSelection(Attribute.clone(Attribute.header, null));
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final imageUrl = await ImageUploadService.uploadImage(File(image.path));
        _controller.document.insert(
          _controller.selection.extentOffset,
          BlockEmbed.image(imageUrl),
        );
      } catch (e) {
        _errorMessage = 'Failed to upload image: $e';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}