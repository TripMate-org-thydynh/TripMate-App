import 'package:flutter/material.dart';

/// Key toàn cục để hiện SnackBar từ nơi không có BuildContext (vd interceptor).
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showGlobalSnack(String message, {bool isError = false}) {
  rootMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : const Color(0xFFFF6A4A),
      ),
    );
}
