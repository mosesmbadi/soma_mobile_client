import 'package:flutter/material.dart';
import 'package:soma/core/widgets/premium_content_card.dart';

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final bool isPremium = story['is_premium'] == true;
    final String content = story['content'] ?? 'No content available.';
    final String title = story['title'] ?? 'No Title';
    final String authorName = story['author']?['name'] ?? 'Unknown Author';

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
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By $authorName',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (story['thumbnail_url'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    story['thumbnail_url'],
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
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
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
