import 'package:flutter/material.dart';
import 'package:samva/main.dart' show navigatorKey;

class Toast {
  static void show(
    String message, {
    int duration = 5,
    Color? backgroundColor,
    String replaceText = 'Exception: ',
  }) {
    final BuildContext? context = navigatorKey.currentContext;
    message = message.replaceAll(replaceText, '').trim();

    if (message.isEmpty || context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 5),
        duration: Duration(seconds: duration),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
