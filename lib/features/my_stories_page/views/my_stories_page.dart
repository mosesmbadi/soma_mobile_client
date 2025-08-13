import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/my_stories_page/viewmodels/my_stories_viewmodel.dart';
import 'package:soma/core/widgets/stories/story_card_row.dart';
import 'package:soma/features/story_detail_page/views/story_detail_page.dart';

class MyStoriesPage extends StatelessWidget {
  const MyStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyStoriesViewModel(),
      child: Consumer<MyStoriesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Stories'),
              backgroundColor: const Color(0xD1E4FFFF),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : viewModel.myStories.isEmpty
                ? const Center(
                    child: Text("You haven't written any stories yet."),
                  )
                : ListView.builder(
                    itemCount: viewModel.myStories.length,
                    itemBuilder: (context, index) {
                      final story = viewModel.myStories[index];
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
                    },
                  ),
          );
        },
      ),
    );
  }
}