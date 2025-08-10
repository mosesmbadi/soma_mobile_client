
import 'package:flutter/material.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';
import 'package:soma/core/widgets/withdraw_bottom_sheet.dart';

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
            backgroundColor: const Color(0xFF333333),
            iconColor: const Color(0xD1E4FFFF),
          ),
          _buildCustomActionButton(
            icon: Icons.upload,
            label: 'Upload Story',
            onPressed: () {
              Navigator.pushNamed(context, '/add_story');
            },
            backgroundColor: const Color(0xFFE2725B),
            iconColor: const Color(0xD1E4FFFF),
          ),
          _buildCustomActionButton(
            icon: Icons.payment,
            label: 'Withdraw',
            onPressed: () {
              WithdrawBottomSheet.show(
                context: context,
                onWithdraw: (amount) {
                  // TODO: Implement actual API call to /api/user/payment-request
                  print('Withdrawal amount: $amount');
                  // Example of how you might call an API (requires http/dio package)
                  // final response = await http.post(
                  //   Uri.parse('https://your-api-url.com/api/user/payment-request'),
                  //   headers: <String, String>{
                  //     'Content-Type': 'application/json; charset=UTF-8',
                  //   },
                  //   body: jsonEncode(<String, dynamic>{
                  //     'amount': amount,
                  //     'paymentMethod': 'M-Pesa', // This would likely come from user selection
                  //   }),
                  // );
                  // if (response.statusCode == 200) {
                  //   print('Withdrawal request sent successfully!');
                  // } else {
                  //   print('Failed to send withdrawal request: ${response.statusCode}');
                  // }
                },
              );
            },
            backgroundColor: const Color(0xFFD1E4FF),
            iconColor: const Color(0xFF333333),
          ),
        ],
      ),
    );
  }
}
