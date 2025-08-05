import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:soma/core/widgets/story_unlock_card.dart';
import 'package:soma/features/story_detail_page/viewmodels/story_detail_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soma/data/story_repository.dart';

class StoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({super.key, required this.story});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final StoryRepository _storyRepository = StoryRepository();

  @override
  void initState() {
    super.initState();
    _initAndReadCount();
  }

  Future<void> _initAndReadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      print('Error: No authentication token found.');
      return;
    }
    _updateReadCount(token);
  }

  Future<void> _updateReadCount(String token) async {
    final String storyId = widget.story['_id'];

    try {
      await _storyRepository.updateStoryReadCount(storyId, token);
      // Optionally, update the local story object or UI if needed
    } catch (e) {
      // Handle error, e.g., log it or show a toast
      print('Error updating read count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String storySlug = widget.story['slug'] ?? '';
    final int estimatedTime = widget.story['estimatedTime'] ?? 30; // Default 30 seconds

    return ChangeNotifierProvider(
      create: (_) => StoryDetailViewModel(storySlug, widget.story['_id'], estimatedTime), 
      child: Consumer<StoryDetailViewModel>(
        builder: (context, viewModel, child) {
          final bool isPremium = widget.story['is_premium'] == true;
          final String title = widget.story['title'] ?? 'No Title';
          final String authorName = widget.story['author']?['name'] ?? 'Unknown Author';
          final String? thumbnailUrl = widget.story['thumbnailUrl'];

          QuillController quillController;
          try {
            final contentJson = jsonDecode(widget.story['content'] ?? '[]');
            final document = Document.fromJson(contentJson);
            quillController = QuillController(
              document: document,
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (_) {
            quillController = QuillController.basic();
          }

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
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('By $authorName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    ),
                  QuillEditor(
                    controller: quillController,
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                    config: QuillEditorConfig(
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                  if (isPremium && !(widget.story['isUnlocked'] == true)) ...[
                    const SizedBox(height: 24),
                    const PremiumContentCard(),
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
