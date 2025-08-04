import 'package:flutter/material.dart';

class StoryCardGrid extends StatelessWidget {
  final Map<String, dynamic> story;
  final VoidCallback onTap;

  const StoryCardGrid({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = story['title'] ?? 'No Title';
    final String authorName = story['author']?['name'] ?? 'Unknown Author';
    final String thumbnailUrl = story['thumbnailUrl'] ?? '';
    final String contentSnippet = story['content']?.split('\n').first ?? '';
    final int reads = story['reads'] ?? 0;
    final double rating = (story['rating'] ?? 4.5).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        // A value of 1 gives a square card.
        aspectRatio: 1, 
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 60),
                      ),
                    )
                  : Container(color: Colors.grey[300]),

              // Gradient overlay for better text visibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(0, 0, 0, 0.7),
                        const Color.fromRGBO(0, 0, 0, 0.0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Text content
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
                    // Combined metadata into a single Row
                    Row(
                      children: [
                        // Author name
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
                        // Reads and rating
                        const Icon(Icons.visibility, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$reads',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_upward, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    )
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
