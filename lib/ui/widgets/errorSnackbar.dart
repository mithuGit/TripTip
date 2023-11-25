import 'package:flutter/material.dart';

class ErrorSnackbar {
  static Future<void> showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ));
    return Future.delayed(const Duration(seconds: 2), () {});
  }
}
