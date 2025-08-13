import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/guest_stories_page/viewmodels/guest_stories_viewmodel.dart';
import 'package:soma/core/widgets/stories/story_card_row.dart';
import 'package:soma/features/story_detail_page/views/story_detail_page.dart';

class GuestStoriesPage extends StatelessWidget {
  const GuestStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuestStoriesViewModel(),
      child: Consumer<GuestStoriesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Guest Stories'),
              backgroundColor: const Color(0xD1E4FFFF),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage.isNotEmpty
                    ? Center(child: Text(viewModel.errorMessage, style: const TextStyle(color: Colors.red)))
                    : viewModel.stories.isEmpty
                        ? const Center(child: Text('No stories available yet.'))
                        : ListView.builder(
                            itemCount: viewModel.stories.length,
                            itemBuilder: (context, index) {
                              final story = viewModel.stories[index];
                              return StoryCardRow(
                                story: story,
                                onTap: () {
                                  if (story['id'] != null) {
                                    viewModel.markStoryAsOpened(story['id']);
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoryDetailPage(story: story),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          );
        },
      ),
    );
  }
}