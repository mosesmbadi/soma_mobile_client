import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showToast(BuildContext context, String message, {bool isSuccess = true}) {
  Flushbar(
    message: message,
    backgroundColor: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      isSuccess ? Icons.check_circle : Icons.error,
      color: Colors.white,
    ),
  ).show(context);
}