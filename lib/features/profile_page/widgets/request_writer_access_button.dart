
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/core/widgets/show_toast.dart';
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
            final result = await viewModel.requestWriterAccess();
            final bool success = result['success'] as bool;
            final String message = result['message'] as String;

            if (success) {
              showToast(context, message, type: ToastType.success);
            } else {
              showToast(context, message, type: ToastType.error);
            }
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
