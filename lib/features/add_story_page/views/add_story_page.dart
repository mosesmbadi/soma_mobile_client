import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class AddStoryPage extends StatelessWidget {
  const AddStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building AddStoryPage');
    return ChangeNotifierProvider(
      create: (_) => AddStoryViewModel(httpClient: null, sharedPreferences: null),
      child: Consumer<AddStoryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add New Story'),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color.fromARGB(255, 48, 48, 48),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            ElevatedButton(
                              onPressed: () => viewModel.publishStory(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xD1E4FFFF),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'Publish',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 88, 88, 88),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        // Story Title
                        TextField(
                          controller: viewModel.titleController,
                          decoration: InputDecoration(
                            labelText: 'Story Title',
                            hintText: 'Enter your story title',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Tag Selection
                        if (viewModel.availableTags.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Tags (1-3):',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: viewModel.availableTags.map<Widget>((tag) {
                                  final String tagId = tag['_id'];
                                  final String tagName = tag['name'];
                                  final bool isSelected = viewModel.selectedTagIds.contains(tagId);
                                  return ChoiceChip(
                                    label: Text(tagName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      viewModel.toggleTagSelection(tagId);
                                    },
                                    selectedColor: Colors.blueAccent,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (viewModel.tagsErrorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    viewModel.tagsErrorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 16.0),

                        // Text manipulation toolbar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            border: Border.all(
                              width: 0.3,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.format_bold),
                                onPressed: viewModel.toggleBold,
                              ),
                              IconButton(
                                icon: const Icon(Icons.format_italic),
                                onPressed: viewModel.toggleItalic,
                              ),
                              IconButton(
                                icon: const Icon(Icons.format_underline),
                                onPressed: viewModel.toggleUnderline,
                              ),
                              IconButton(
                                icon: const Icon(Icons.image),
                                onPressed: viewModel.pickImage,
                              ),
                              IconButton(
                                icon: const Icon(Icons.mood),
                                onPressed: viewModel.pickImage,
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'strikethrough') {
                                    viewModel.toggleStrikeThrough();
                                  } else if (value == 'link') {
                                    viewModel.toggleLink();
                                  } else if (value == 'clear_formatting') {
                                    viewModel.clearFormatting();
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'strikethrough',
                                        child: Text('Strikethrough'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'link',
                                        child: Text('Link'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'clear_formatting',
                                        child: Text('Clear Formatting'),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Story Content Editor
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: QuillEditor(
                                    controller: viewModel.controller,
                                    focusNode: viewModel.focusNode,
                                    scrollController:
                                        viewModel.scrollController,
                                    config: QuillEditorConfig(
                                      placeholder: 'Story Content',
                                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16.0),

                              if (viewModel.errorMessage.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    viewModel.errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
