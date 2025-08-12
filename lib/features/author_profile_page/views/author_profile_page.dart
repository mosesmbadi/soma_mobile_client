import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/author_profile_page/viewmodels/author_profile_viewmodel.dart';
import 'package:soma/core/widgets/story_card_row.dart'; // Assuming this widget is available
import 'package:soma/features/story_detail_page/views/story_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthorProfilePage extends StatelessWidget {
  final String authorId;

  const AuthorProfilePage({super.key, required this.authorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Author Profile')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Author Profile')),
            body: Center(
              child: Text('Error loading preferences: ${snapshot.error}'),
            ),
          );
        } else {
          final SharedPreferences prefs = snapshot.data!;
          final http.Client client = http.Client(); // Create a new client for this viewmodel

          return ChangeNotifierProvider(
            create: (_) => AuthorProfileViewModel(
              authorId: authorId,
              prefs: prefs,
              client: client,
            ),
            child: Consumer<AuthorProfileViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Author Profile')),
                    body: const Center(child: CircularProgressIndicator()),
                  );
                } else if (viewModel.errorMessage.isNotEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Author Profile')),
                    body: Center(
                      child: Text(
                        viewModel.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(viewModel.authorName),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Stories by ${viewModel.authorName}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (viewModel.authorStories.isEmpty)
                            const Center(
                              child: Text('No stories found for this author.'),
                            )
                          else
                            Column(
                              children: viewModel.authorStories.map((story) {
                                return StoryCardRow(
                                  story: story,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StoryDetailPage(story: story),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          );
        }
      },
    );
  }
}
