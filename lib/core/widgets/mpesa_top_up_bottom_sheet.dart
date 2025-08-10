import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MpesaTopUpBottomSheet {
  static void show({
    required BuildContext context,
    String? initialPhoneNumber,
    required Function(double amount, String phoneNumber) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return _MpesaTopUpBottomSheetContent(
          initialPhoneNumber: initialPhoneNumber,
          onConfirm: onConfirm,
        );
      },
    );
  }
}

class _MpesaTopUpBottomSheetContent extends StatefulWidget {
  final String? initialPhoneNumber;
  final Function(double amount, String phoneNumber) onConfirm;

  const _MpesaTopUpBottomSheetContent({
    super.key,
    this.initialPhoneNumber,
    required this.onConfirm,
  });

  @override
  State<_MpesaTopUpBottomSheetContent> createState() => _MpesaTopUpBottomSheetContentState();
}

class _MpesaTopUpBottomSheetContentState extends State<_MpesaTopUpBottomSheetContent> {
  late TextEditingController _amountController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _phoneNumberController = TextEditingController(text: widget.initialPhoneNumber);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount in KSh',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (254...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                final phoneNumber = _phoneNumberController.text;

                if (amount != null && amount > 0 && phoneNumber.isNotEmpty) {
                  widget.onConfirm(amount, phoneNumber);
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
  }
}