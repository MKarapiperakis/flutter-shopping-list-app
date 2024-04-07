import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
    BuildContext context,
    String message,
    Icon icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            icon,
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: color,
      ),
    );
  }
}
