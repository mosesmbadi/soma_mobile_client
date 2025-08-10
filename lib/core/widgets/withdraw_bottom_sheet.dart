import 'package:flutter/material.dart';

class WithdrawBottomSheet {
  static void show({
    required BuildContext context,
    required Function(double amount) onWithdraw,
  }) {
    final TextEditingController amountController = TextEditingController();
    double convertedKsh = 0.0; // Placeholder for conversion

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Withdraw Tokens',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount in Tokens',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Placeholder for real-time conversion
                      final amount = double.tryParse(value) ?? 0.0;
                      setState(() {
                        convertedKsh = amount * 100; // Example: 1 token = 100 KSh
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Equivalent in KSh: ${convertedKsh.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferred Payment Method: M-Pesa (Placeholder)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null && amount > 0) {
                        onWithdraw(amount);
                        Navigator.pop(context); // Close the bottom sheet
                      } else {
                        // Show an error or a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid amount')),
                        );
                      }
                    },
                    child: const Text('Confirm Withdrawal'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      amountController.dispose();
    });
  }
}
