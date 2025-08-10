import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:share_plus/share_plus.dart'; // For social sharing
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart';

class FloatingShareOptions extends StatelessWidget {
  final AddStoryViewModel viewModel;

  const FloatingShareOptions({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Congratulations! Story Published Successfully! Share with your ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Shareable Link
              Row(
                children: [
                  Expanded(
                    child: Text(
                      viewModel.publishedStoryUrl ?? 'Link not available',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      if (viewModel.publishedStoryUrl != null) {
                        Clipboard.setData(ClipboardData(text: viewModel.publishedStoryUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied to clipboard!')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Social Media Share Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (viewModel.publishedStoryUrl != null) {
                        Share.share('Check out my story: ${viewModel.publishedStoryUrl}');
                      }
                    },
                    icon: const Icon(Icons.facebook),
                    label: const Text('Facebook'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (viewModel.publishedStoryUrl != null) {
                        Share.share('Check out my story: ${viewModel.publishedStoryUrl}');
                      }
                    },
                    icon: const Icon(Icons.share), // Or a Twitter icon if available
                    label: const Text('Twitter'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  viewModel.hideShareOptions();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
