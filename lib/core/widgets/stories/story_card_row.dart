import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soma/core/utils/quill_utils.dart';

class StoryCardRow extends StatelessWidget {
  final Map<String, dynamic> story;
  final VoidCallback onTap;

  const StoryCardRow({
    super.key,
    required this.story,
    required this.onTap,
  });

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
    final String contentSnippet =
        QuillUtils.extractPlainText(story['content'] ?? '[]', maxLength: 150);
    final int reads =
        story['reads'] ?? story['readCount'] ?? story['views'] ?? 0;
    final double upvotes = (story['upvotes'] ?? 0).toDouble();
    final DateTime createdAt =
        DateTime.tryParse(story['createdAt'] ?? '') ?? DateTime.now();
    final String formattedDate = DateFormat('MMM d').format(createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contentSnippet,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Meta Info Row
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            authorName,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),                        
                        Icon(Icons.arrow_upward, size: 12, color: Colors.grey[600],),
                        const SizedBox(width: 4),
                        Text(
                        '$upvotes',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.visibility, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '$reads',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    // Tags
                    if (story['tags'] != null &&
                        story['tags'] is List &&
                        (story['tags'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: 0.0,
                          children: (story['tags'] as List<dynamic>)
                              .map((tag) {
                            final Map<String, dynamic> tagMap =
                                tag as Map<String, dynamic>;
                            return Chip(
                              label: Text(
                                tagMap['name'],
                                style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF333333),
                              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: -3.0),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                  horizontal: -2.0, vertical: -4.0),
                              // padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right side: Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: thumbnailUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}