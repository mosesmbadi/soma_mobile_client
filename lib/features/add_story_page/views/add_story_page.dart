import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import the new widgets
import 'package:soma/features/add_story_page/views/add_story_app_bar.dart';
import 'package:soma/features/add_story_page/views/publish_save_row.dart';
import 'package:soma/features/add_story_page/views/story_title_input.dart';
import 'package:soma/features/add_story_page/views/tag_selection_section.dart';
import 'package:soma/features/add_story_page/views/text_manipulation_toolbar.dart';
import 'package:soma/features/add_story_page/views/story_content_editor.dart';
import 'package:soma/features/add_story_page/views/floating_share_options.dart';

class AddStoryPage extends StatelessWidget {
  const AddStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building AddStoryPage');
    return ChangeNotifierProvider(
      create: (context) => AddStoryViewModel(
        httpClient: Provider.of<http.Client>(context, listen: false),
        sharedPreferences: Provider.of<SharedPreferences>(context, listen: false),
      ),
      child: Consumer<AddStoryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: const AddStoryAppBar(),
            body: Stack(
              children: [
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            PublishSaveRow(viewModel: viewModel),
                            const SizedBox(height: 16.0),
                            StoryTitleInput(viewModel: viewModel),
                            const SizedBox(height: 16.0),
                            if (viewModel.availableTags.isNotEmpty)
                              TagSelectionSection(viewModel: viewModel),
                            const SizedBox(height: 16.0),
                            TextManipulationToolbar(viewModel: viewModel),
                            const SizedBox(height: 16.0),
                            StoryContentEditor(viewModel: viewModel),
                          ],
                        ),
                      ),
                if (viewModel.showShareOptions)
                  ModalBarrier(
                    dismissible: false, // Prevent dismissing by tapping outside
                    color: Colors.black.withOpacity(0.5), // Semi-transparent black
                  ),
                if (viewModel.showShareOptions)
                  Align(
                    alignment: Alignment.center, // Center the widget
                    child: FloatingShareOptions(viewModel: viewModel),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}