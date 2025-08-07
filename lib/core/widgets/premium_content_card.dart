import 'package:flutter/material.dart';
import 'package:soma/data/user_repository.dart';

enum PremiumCardType {
  unlock,
  topUp,
}

class PremiumContentCard extends StatelessWidget {
  final int neededTokens;
  final PremiumCardType cardType;
  final VoidCallback onButtonPressed;
  final bool isLoading; // New parameter

  const PremiumContentCard({
    super.key,
    this.neededTokens = 1,
    required this.cardType,
    required this.onButtonPressed,
    this.isLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserRepository().getCurrentUserDetails(),
      builder: (context, snapshot) {
        int currentBalance = 0;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          currentBalance = snapshot.data?['tokens'] ?? 0;
        } else if (snapshot.hasError) {
          // Handle error, maybe log it or show a default value
        }

        String title;
        String description;
        String buttonText;
        IconData icon;

        if (cardType == PremiumCardType.unlock) {
          title = 'Unlock Story';
          description = "Unlock this premium story to continue reading.";
          buttonText = 'Unlock Now';
          icon = Icons.lock_open;
        } else {
          // PremiumCardType.topUp
          title = 'Top Up Account';
          description = "You've reached your free reading limit. Top up your account to continue enjoying this amazing story.";
          buttonText = 'Top Up Now';
          icon = Icons.account_balance_wallet;
        }

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top notch
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Icon circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                // Balance info (only for unlock, or if we want to show current balance for top-up too)
                if (cardType == PremiumCardType.unlock) // Only show balance for unlock
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTokenRow('Current Balance', currentBalance),
                        _buildTokenRow('Needed to Unlock', neededTokens),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Token packages (only for top-up)
                if (cardType == PremiumCardType.topUp) ...[
                  _buildTokenOption('100 Tokens', 'Ksh120.99', highlight: true),
                  const SizedBox(height: 12),
                  _buildTokenOption('50 Tokens', 'Ksh10.99'),
                  const SizedBox(height: 20),
                ],
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onButtonPressed, // Disable when loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                        : Text(
                            buttonText,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Maybe Later button (only for unlock)
                if (cardType == PremiumCardType.unlock && !isLoading) // Hide when loading
                  Text('Maybe Later', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTokenRow(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenOption(String title, String price, {bool highlight = false}) {
    final Color borderColor = highlight ? const Color(0xFF9FE2BF) : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (highlight)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'Best Value',
                    style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
