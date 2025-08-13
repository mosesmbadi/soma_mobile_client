import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/data/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum UnlockCardType { unlock, topUp }

class StoryUnlockCard extends StatelessWidget {
  final int neededTokens;
  final UnlockCardType cardType;
  final Function() onButtonPressed;
  final bool isLoading;

  const StoryUnlockCard({
    super.key,
    this.neededTokens = 1,
    required this.cardType,
    required this.onButtonPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepository = Provider.of<UserRepository>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: userRepository.getCurrentUserDetails(),
      builder: (context, snapshot) {
        int currentBalance = 0;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          currentBalance = (snapshot.data?['tokens'] as num?)?.toInt() ?? 0;
        } else if (snapshot.hasError) {
          print('Error fetching current user details in StoryUnlockCard: ${snapshot.error}');
        }

        String title;
        String description;
        String buttonText;
        IconData icon;

        if (cardType == UnlockCardType.unlock) {
          title = 'Unlock Story';
          description = "Unlock this premium story to continue reading.";
          buttonText = 'Unlock Now';
          icon = Icons.lock_open;
        } else {
          title = 'Top Up Account';
          description =
              "You've reached your free reading limit. Top up your account to continue enjoying this amazing story.";
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
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                if (cardType == UnlockCardType.unlock)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildTokenRow(
                            'Current Balance',
                            currentBalance,
                          ),
                        ),
                        Expanded(
                          child: _buildTokenRow(
                            'Needed to Unlock',
                            neededTokens,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (cardType == UnlockCardType.topUp) ...[
                  _buildTokenOption('100 Tokens', 'Ksh120.99', highlight: true),
                  const SizedBox(height: 12),
                  _buildTokenOption('50 Tokens', 'Ksh10.99'),
                  const SizedBox(height: 20),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (cardType == UnlockCardType.unlock && !isLoading)
                  const Text('Maybe Later', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildTokenRow(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildTokenOption(
    String title,
    String price, {
    bool highlight = false,
  }) {
    final Color borderColor = highlight
        ? const Color(0xFF9FE2BF)
        : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (highlight)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'Best Value',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}