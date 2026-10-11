import 'package:flutter/material.dart';

class ToastUtils {
  static void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 4),
        width: 120,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        content: Text(message ?? '加载成功', textAlign: TextAlign.center),
      ),
    );
  }
}
