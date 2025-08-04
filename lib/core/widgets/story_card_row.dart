import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final String authorName = story['author']?['name'] ?? 'Unknown Author';
    final String thumbnailUrl = story['thumbnailUrl'] ?? '';
    final String contentSnippet = story['content']?.split('\n').first ?? 'No Content';

    final int reads = story['reads'] ?? 0;
    final int commentsCount = (story['comments'] as List?)?.length ?? 0;
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
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle or content snippet
                    Text(
                      contentSnippet,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Refactored Row for all metadata
                    Row(
                      children: [
                        // Author
                        const CircleAvatar(
                          radius: 10,
                          child: Icon(Icons.person, size: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Date
                        Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),

                        // Views/Reads
                        Icon(Icons.visibility, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$reads', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),

                        // Comments
                        Icon(Icons.comment, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$commentsCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),

                        // Votes/Rates
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('$rating', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Thumbnail image on right
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