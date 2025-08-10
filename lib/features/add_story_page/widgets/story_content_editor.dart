import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class StoryContentEditor extends StatelessWidget {
  final AddStoryViewModel viewModel;

  const StoryContentEditor({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}
