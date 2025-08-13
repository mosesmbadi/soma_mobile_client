import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';
import 'package:intl/intl.dart';

class ProfileStoryListSection extends StatelessWidget {
  const ProfileStoryListSection({super.key});

  Widget _buildRecentReadItem({
    required String title,
    required String author,
    required String date,
    required String thumbnailUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // container for Recent Reads
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(thumbnailUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'By: $author',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfilePageViewModel>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                viewModel.userData!['role'] == 'reader'
                    ? (viewModel.recentReads.isNotEmpty
                          ? 'Recent Reads'
                          : 'Trending Stories')
                    : (viewModel.myStories.isNotEmpty
                          ? 'My Stories'
                          : 'Trending Stories'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle view all based on what's displayed
                  if (viewModel.userData!['role'] == 'reader') {
                    if (viewModel.recentReads.isNotEmpty) {
                      // Navigate to Recent Reads page
                    } else {
                      // Navigate to Trending Stories page
                    }
                  } else {
                    if (viewModel.myStories.isNotEmpty) {
                      // Navigate to My Stories page
                    } else {
                      // Navigate to Trending Stories page
                    }
                  }
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            if (viewModel.userData!['role'] == 'reader') {
              return (viewModel.recentReads.isNotEmpty)
                  ? Column(
                      children: viewModel.recentReads
                          .map((story) {
                            if (story is Map<String, dynamic>) {
                              return _buildRecentReadItem(
                                title: story['title'] ?? 'No Title',
                                author:
                                    (story['author'] is Map<String, dynamic>)
                                    ? story['author']['name'] ??
                                          'Unknown Author'
                                    : (story['author'] is String)
                                    ? story['author']
                                    : 'Unknown Author',
                                date: story['createdAt'] != null
                                    ? DateFormat('MMM d, yyyy').format(
                                        DateTime.parse(story['createdAt']),
                                      )
                                    : '',
                                thumbnailUrl:
                                    story['thumbnail'] as String? ?? '',
                              );
                            } else {
                              return const SizedBox.shrink(); // Or a placeholder widget
                            }
                          })
                          .toList()
                          .cast<Widget>(),
                    )
                  : (viewModel.trendingStories.isNotEmpty)
                  ? Column(
                      children: viewModel.trendingStories
                          .map((story) {
                            if (story is Map<String, dynamic>) {
                              return _buildRecentReadItem(
                                title: story['title'] ?? 'No Title',
                                author:
                                    (story['author'] is Map<String, dynamic>)
                                    ? story['author']['name'] ??
                                          'Unknown Author'
                                    : (story['author'] is String)
                                    ? story['author']
                                    : 'Unknown Author',
                                date: story['createdAt'] != null
                                    ? DateFormat('MMM d, yyyy').format(
                                        DateTime.parse(story['createdAt']),
                                      )
                                    : '',
                                thumbnailUrl:
                                    story['thumbnail'] as String? ?? ' ',
                              );
                            } else {
                              return const SizedBox.shrink(); // Or a placeholder widget
                            }
                          })
                          .toList()
                          .cast<Widget>(),
                    )
                  : const SizedBox.shrink();
            } else if (viewModel.userData!['role'] == 'writer') {
              return (viewModel.myStories.isNotEmpty)
                  ? Column(
                      children: viewModel.myStories
                          .map((story) {
                            if (story is Map<String, dynamic>) {
                              return _buildRecentReadItem(
                                title: story['title'] ?? 'No Title',
                                author:
                                    (story['author'] is Map<String, dynamic>)
                                    ? story['author']['name'] ??
                                          'Unknown Author'
                                    : (story['author'] is String)
                                    ? story['author']
                                    : 'Unknown Author',
                                date: story['createdAt'] != null
                                    ? DateFormat('MMM d, yyyy').format(
                                        DateTime.parse(story['createdAt']),
                                      )
                                    : '',
                                thumbnailUrl:
                                    story['thumbnail'] as String? ?? ' ',
                              );
                            } else {
                              return const SizedBox.shrink(); // Or a placeholder widget
                            }
                          })
                          .toList()
                          .cast<Widget>(),
                    )
                  : (viewModel.trendingStories.isNotEmpty)
                  ? Column(
                      children: viewModel.trendingStories
                          .map((story) {
                            if (story is Map<String, dynamic>) {
                              return _buildRecentReadItem(
                                title: story['title'] ?? 'No Title',
                                author:
                                    (story['author'] is Map<String, dynamic>)
                                    ? story['author']['name'] ??
                                          'Unknown Author'
                                    : (story['author'] is String)
                                    ? story['author']
                                    : 'Unknown Author',
                                date: story['createdAt'] != null
                                    ? DateFormat('MMM d, yyyy').format(
                                        DateTime.parse(story['createdAt']),
                                      )
                                    : '',
                                thumbnailUrl:
                                    story['thumbnail'] as String? ?? ' ',
                              );
                            } else {
                              return const SizedBox.shrink(); // Or a placeholder widget
                            }
                          })
                          .toList()
                          .cast<Widget>(),
                    )
                  : const SizedBox.shrink();
            } else {
              return const SizedBox.shrink(); // Handle other roles or no stories
            }
          },
        ),
      ],
    );
  }
}
