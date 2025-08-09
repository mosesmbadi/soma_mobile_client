
import 'package:flutter/material.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';

class ProfileActionButtons extends StatelessWidget {
  final ProfilePageViewModel viewModel;

  const ProfileActionButtons({super.key, required this.viewModel});

  Widget _buildCustomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, size: 20, color: iconColor),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCustomActionButton(
            icon: Icons.wallet,
            label: 'Top up',
            onPressed: () => viewModel.showTopUpDialog(context),
            backgroundColor: const Color(0xFFF0E6FF),
            iconColor: const Color(0xD1E4FFFF),
          ),
          _buildCustomActionButton(
            icon: Icons.upload,
            label: 'Upload Story',
            onPressed: () {
              Navigator.pushNamed(context, '/add_story');
            },
            backgroundColor: const Color(0xFFE0B0FF),
            iconColor: const Color(0xD1E4FFFF),
          ),
          _buildCustomActionButton(
            icon: Icons.payment,
            label: 'Withdraw',
            onPressed: () => viewModel.showWithdrawDialog(context),
            backgroundColor: const Color(0xFFF0E6FF),
            iconColor: const Color(0xD1E4FFFF),
          ),
        ],
      ),
    );
  }
}
