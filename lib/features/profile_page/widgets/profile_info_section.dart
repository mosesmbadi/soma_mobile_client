
import 'package:flutter/material.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';

class ProfileInfoSection extends StatelessWidget {
  final ProfilePageViewModel viewModel;

  const ProfileInfoSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  viewModel.userData!['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Positioned(
                  top: -5, // Adjust this value to control vertical position
                  right: -50, // Adjust this value to control horizontal position
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100, // Background color
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Border radius
                    ),
                    child: Text(
                      viewModel.userData!['role'],
                      style: const TextStyle(
                        fontSize: 12, // Smaller font size
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),
        // User Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '${viewModel.userData!['monthly_upvote'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${viewModel.userData!['total_monthly_reads'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wallet,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${viewModel.userData!['tokens'] ?? 0} Tokens',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
