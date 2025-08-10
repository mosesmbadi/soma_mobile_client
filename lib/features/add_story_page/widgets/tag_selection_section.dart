import 'package:flutter/material.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class TagSelectionSection extends StatelessWidget {
  final AddStoryViewModel viewModel;

  const TagSelectionSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
