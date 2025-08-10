import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

enum ToastType { success, error, warning, info }

void showToast(BuildContext context, String message, {ToastType type = ToastType.success}) {
  Color backgroundColor;
  IconData iconData;

  switch (type) {
    case ToastType.success:
      backgroundColor = const Color(0xFFCFFDBC); // Light Green
      iconData = Icons.check_circle;
      break;
    case ToastType.error:
      backgroundColor = const Color(0xFFE2725B); // Reddish Orange
      iconData = Icons.error;
      break;
    case ToastType.warning:
      backgroundColor = Colors.orange; // Standard Orange
      iconData = Icons.warning;
      break;
    case ToastType.info:
      backgroundColor = Colors.blue; // Standard Blue
      iconData = Icons.info;
      break;
  }

  Flushbar(
    message: message,
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      iconData,
      color: Colors.white,
    ),
  ).show(context);
}