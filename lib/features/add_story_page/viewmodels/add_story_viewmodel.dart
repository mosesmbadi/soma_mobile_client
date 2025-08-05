import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/services/image_upload_service.dart';
import '../../../core/config/environment.dart';

const String apiUrl = '${Environment.backendUrl}/api/stories';

class AddStoryViewModel extends ChangeNotifier {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String _errorMessage = '';
  bool _isLoading = false;

  String? _thumbnailUrl;

  // Getters
  QuillController get controller => _controller;
  TextEditingController get titleController => _titleController;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  FocusNode get focusNode => _focusNode;
  ScrollController get scrollController => _scrollController;
  String? get thumbnailUrl => _thumbnailUrl;

  AddStoryViewModel() {
    _loadSavedStory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedStory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedTitle = prefs.getString('draft_story_title');
    final String? savedContent = prefs.getString('draft_story_content');

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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('draft_story_title', _titleController.text);
      await prefs.setString(
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

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

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
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'content': contentToSend,
          'thumbnailUrl': thumbnailUrl,
        }),
      );

      if (response.statusCode == 201) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story published successfully!')),
        );
        _titleController.clear();
        _controller.clear();
        await prefs.remove('draft_story_title');
        await prefs.remove('draft_story_content');
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
    _controller.formatSelection(Attribute.clone(Attribute.link, null));
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
