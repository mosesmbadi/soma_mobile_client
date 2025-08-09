import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/home_page/viewmodels/home_page_viewmodel.dart';
import 'package:soma/core/widgets/story_card_grid.dart'; // StoryCardMain is here
import 'package:soma/core/widgets/story_card_row.dart';
import 'package:soma/features/story_detail_page/views/story_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewModel(),
      child: Consumer<HomePageViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                viewModel.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (viewModel.stories.isEmpty && viewModel.trendingStories.isEmpty) {
            return const Center(child: Text('No stories available yet.'));
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    backgroundColor: const Color.fromARGB(209, 255, 255, 255),
                    automaticallyImplyLeading: false, 
                    toolbarHeight: 10.0,
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      'Trending Stories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Top scrollable cards (using StoryCardMain for trending stories)
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.trendingStories.length,
                      itemBuilder: (context, index) {
                        final story = viewModel.trendingStories[index];
                        return StoryCardGrid(
                          story: story,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StoryDetailPage(storyId: story['_id']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      'Latest Stories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Latest stories as rows (using StoryCardRow)
                  Column(
                    children: viewModel.stories.map((story) {
                      return StoryCardRow(
                        story: story,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StoryDetailPage(storyId: story['_id']),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
