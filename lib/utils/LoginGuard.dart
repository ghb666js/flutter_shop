import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/UserController.dart';

/// 登录态拦截：未登录时弹窗提示去登录。
/// 返回 true 表示已登录，可继续后续操作；返回 false 表示未登录（已弹窗），调用方应中断。
bool requireLogin(BuildContext context) {
  final user = Get.find<UserController>().user.value;
  if (user.id.isNotEmpty) return true;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('提示'),
      content: Text('未登录账号，请先登录'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, '/login');
          },
          child: Text('去登录'),
        ),
      ],
    ),
  );
  return false;
}
