import 'package:flutter/material.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class PublishSaveRow extends StatelessWidget {
  final AddStoryViewModel viewModel;

  const PublishSaveRow({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
