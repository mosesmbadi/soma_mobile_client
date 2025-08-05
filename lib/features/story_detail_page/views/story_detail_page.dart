import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:soma/core/widgets/premium_content_card.dart';

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final bool isPremium = story['is_premium'] == true;
    final String title = story['title'] ?? 'No Title';
    final String authorName = story['author']?['name'] ?? 'Unknown Author';

    final String? thumbnailUrl = story['thumbnailUrl'];

    // Parse and create Quill document and controller
    QuillController quillController;
    try {
      final contentJson = jsonDecode(story['content'] ?? '[]');
      final document = Document.fromJson(contentJson);
      quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback for invalid content
      quillController = QuillController.basic();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 232, 186, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Author
            Text(
              'By $authorName',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Thumbnail image if available
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

            // Story content rendered by QuillEditor (read-only)
            QuillEditor(
              controller: quillController,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              config: QuillEditorConfig(
                // readOnly: true,
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                padding: const EdgeInsets.all(0),
              ),
            ),
            // Premium content lock
            if (isPremium && !(story['isUnlocked'] == true)) ...[
              const SizedBox(height: 24),
              const PremiumContentCard(),
            ],
          ],
        ),
      ),
    );
  }
}
