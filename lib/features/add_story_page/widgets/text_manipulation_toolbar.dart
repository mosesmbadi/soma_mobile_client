import 'package:flutter/material.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class TextManipulationToolbar extends StatelessWidget {
  final AddStoryViewModel viewModel;

  const TextManipulationToolbar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
