import 'package:flutter/material.dart';
import 'package:soma/core/utils/quill_utils.dart';

class StoryCardGrid extends StatelessWidget {
  final Map<String, dynamic> story;
  final VoidCallback onTap;

  const StoryCardGrid({super.key, required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title = story['title'] ?? 'No Title';
    final dynamic authorData = story['author'];
    final String authorName = (authorData is Map<String, dynamic>)
        ? authorData['name'] ?? 'Unknown Author'
        : (authorData is String)
        ? authorData
        : 'Unknown Author';
    final String thumbnailUrl = story['thumbnailUrl'] ?? '';
    final String contentSnippet = QuillUtils.extractPlainText(
      story['content'] ?? '[]',
      maxLength: 100,
    );

    final int reads =
        story['reads'] ?? story['readCount'] ?? story['views'] ?? 0;
    final int upvotes = (story['upvotes'] is int)
        ? story['upvotes'] as int
        : 0; // Ensure upvotes is an integer

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 60),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 60),
                    ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.7),
                        Color.fromRGBO(0, 0, 0, 0.0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contentSnippet.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        contentSnippet,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Display Tags
                    if (story['tags'] != null && story['tags'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Wrap(
                          spacing: 6.0,
                          runSpacing: 0.0,
                          children: (story['tags'] as List<dynamic>).map((tag) {
                            String tagName;
                            if (tag is Map<String, dynamic>) {
                              tagName = tag['name'] ?? '';
                            } else if (tag is String) {
                              tagName = tag;
                            } else {
                              tagName = ''; // Default or handle unexpected type
                            }
                            return Chip(
                              label: Text(
                                tagName,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: const Color(0xFF333333),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'By $authorName',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.visibility,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$reads',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_upward,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$upvotes', // Display upvotes
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
