
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';

class RequestWriterAccessButton extends StatelessWidget {
  const RequestWriterAccessButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfilePageViewModel>(context);

    if (viewModel.userData!['role'] == 'reader') {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 90.0,
          vertical: 10.0,
        ),
        child: ElevatedButton.icon(
          label: const Text('Request Writer Access'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final success = await viewModel.requestWriterAccess();
            final message = success
                ? 'Request sent successfully!'
                : 'Failed to send request.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
