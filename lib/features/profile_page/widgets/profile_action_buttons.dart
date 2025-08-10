
import 'package:flutter/material.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';
import 'package:soma/core/widgets/withdraw_bottom_sheet.dart';
import 'package:soma/core/widgets/mpesa_top_up_bottom_sheet.dart';

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
            onPressed: () {
              MpesaTopUpBottomSheet.show(
                context: context,
                onConfirm: (amount, phoneNumber) async {
                  await viewModel.requestMpesaTopUp(amount, phoneNumber, context);
                },
              );
            },
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
                onWithdraw: (amount) async {
                  await viewModel.requestWithdrawal(amount, context);
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
