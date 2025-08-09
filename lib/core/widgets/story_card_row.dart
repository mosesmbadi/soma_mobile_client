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
    final String contentSnippet = QuillUtils.extractPlainText(story['content'] ?? '[]', maxLength: 150);
    final int reads = story['reads'] ?? story['readCount'] ?? story['views'] ?? 0;
    final double rating = (story['rating'] ?? 4.5).toDouble();
    final DateTime createdAt = DateTime.tryParse(story['createdAt'] ?? '') ?? DateTime.now();
    String formattedDate = DateFormat('MMM d').format(createdAt);

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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(radius: 10, child: Icon(Icons.person, size: 12)),
                              const SizedBox(width: 4),
                              Expanded(child: Text(authorName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text('$reads', style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),

                        // Display Tags
                        if (story['tags'] != null && story['tags'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Wrap(
                              spacing: 2.0, // reduced spacing between chips
                              runSpacing: 0.0,
                              children: (story['tags'] as List<dynamic>).map((tag) {
                                final Map<String, dynamic> tagMap = tag as Map<String, dynamic>;
                                return Chip(
                                  label: Text(
                                    tagMap['name'],
                                    style: const TextStyle(fontSize: 9, color: Color(0xFFFFFFFF)), // smaller font
                                  ),
                                  backgroundColor: Color(0xFF333333),
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 4.0), // less padding
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(horizontal: -2.0, vertical: -4.0), // more compact
                                  padding: EdgeInsets.zero, // minimal padding
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(width: 12),
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
