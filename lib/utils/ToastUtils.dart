import 'package:flutter/material.dart';

class ToastUtils {
  static bool isShowing = false;
  static void showToast(
    BuildContext context,
    String message, {
    double? showWith = 120,
  }) {
    if (ToastUtils.isShowing) return;
    ToastUtils.isShowing = true;
    Future.delayed(Duration(seconds: 3), () {
      ToastUtils.isShowing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        width: showWith,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        content: Text(message ?? '加载成功', textAlign: TextAlign.center),
      ),
    );
  }
}
