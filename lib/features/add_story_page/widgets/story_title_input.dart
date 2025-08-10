import 'package:flutter/material.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class StoryTitleInput extends StatelessWidget {
  final AddStoryViewModel viewModel;

  const StoryTitleInput({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}
