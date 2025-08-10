import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MpesaTopUpBottomSheet {
  static void show({
    required BuildContext context,
    required Function(double amount, String phoneNumber) onConfirm,
  }) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'M-Pesa Top Up',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount in KSh',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (254...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        final phoneNumber = phoneNumberController.text;

                        if (amount != null && amount > 0 && phoneNumber.isNotEmpty) {
                          onConfirm(amount, phoneNumber);
                          Navigator.pop(context); // Close the bottom sheet
                        } else {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid amount and phone number')),
                            );
                          });
                        }
                      },
                      child: const Text('Confirm Top Up'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      amountController.dispose();
      phoneNumberController.dispose();
    });
  }
}
