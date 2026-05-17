import 'package:flutter/material.dart';
import 'package:my_app/core/error_message.dart';
import 'package:my_app/theme/app_theme.dart';

void showAppSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showErrorSnackBar(BuildContext context, Object error) {
  showAppSnackBar(
    context,
    message: friendlyError(error),
    isError: true,
  );
}
