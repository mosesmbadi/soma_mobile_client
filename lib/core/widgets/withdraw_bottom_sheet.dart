import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class WithdrawBottomSheet {
  static void show({
    required BuildContext context,
    required Function(double amount) onWithdraw,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return _WithdrawBottomSheetContent(onWithdraw: onWithdraw);
      },
    );
  }
}

class _WithdrawBottomSheetContent extends StatefulWidget {
  final Function(double amount) onWithdraw;

  const _WithdrawBottomSheetContent({super.key, required this.onWithdraw});

  @override
  State<_WithdrawBottomSheetContent> createState() => _WithdrawBottomSheetContentState();
}

class _WithdrawBottomSheetContentState extends State<_WithdrawBottomSheetContent> {
  final TextEditingController _amountController = TextEditingController();
  double _convertedKsh = 0.0; // Placeholder for conversion

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateConversion);
  }

  void _updateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _convertedKsh = amount * 100; // Example: 1 token = 100 KSh
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateConversion);
    _amountController.dispose();
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
              'Withdraw Tokens',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount in Tokens',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Equivalent in KSh: ${_convertedKsh.toStringAsFixed(2)}',
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
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  widget.onWithdraw(amount);
                  Navigator.pop(context); // Close the bottom sheet
                } else {
                  // Show an error or a snackbar
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                  });
                }
              },
              child: const Text('Confirm Withdrawal'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}