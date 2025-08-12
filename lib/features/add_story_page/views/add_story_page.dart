import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soma/features/add_story_page/widgets/add_story_app_bar.dart';
import 'package:soma/features/add_story_page/widgets/publish_save_row.dart';
import 'package:soma/features/add_story_page/widgets/story_title_input.dart';
import 'package:soma/features/add_story_page/widgets/tag_selection_section.dart';
import 'package:soma/features/add_story_page/widgets/text_manipulation_toolbar.dart';
import 'package:soma/features/add_story_page/widgets/story_content_editor.dart';
import 'package:soma/features/add_story_page/widgets/floating_share_options.dart';

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
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              PublishSaveRow(viewModel: viewModel),
                              const SizedBox(height: 16.0),
                              StoryTitleInput(viewModel: viewModel),
                              const SizedBox(height: 16.0),
                              // Show the tag selection section only if there are available tags
                              // will cause issues if no tags are available
                              // TODO: In production tags MUST be available, that is not promised however
                              //and might cause silent bug
                              if (viewModel.availableTags.isNotEmpty)
                                TagSelectionSection(viewModel: viewModel),
                              const SizedBox(height: 16.0),
                              TextManipulationToolbar(viewModel: viewModel),
                              const SizedBox(height: 16.0),
                              // StoryContentEditor is now inside a scrollable view
                              StoryContentEditor(viewModel: viewModel),
                            ],
                          ),
                        ),
                      ),
                if (viewModel.showShareOptions)
                  ModalBarrier(
                    dismissible: false,
                    color: Colors.black.withOpacity(0.5),
                  ),
                if (viewModel.showShareOptions)
                  Align(
                    alignment: Alignment.center,
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