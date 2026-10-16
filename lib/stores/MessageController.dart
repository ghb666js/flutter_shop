import 'package:get/get.dart';
import 'package:hm_shop/services/NotificationService.dart';
import 'package:hm_shop/viewmodels/message.dart';

class MessageController extends GetxController {
  RxList<AppMessage> messages = <AppMessage>[].obs;

  int _idCounter = 0;

  /// 未读消息数
  int get unreadCount => messages.where((m) => !m.read).length;

  /// 添加一条系统消息并发送本地通知
  void addMessage(String title, String content) {
    final msg = AppMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      time: DateTime.now(),
    );
    messages.insert(0, msg);
    _idCounter++;

    // 发送手机弹窗通知
    notificationService.showNotification(
      id: _idCounter,
      title: title,
      body: content,
    );
  }

  /// 全部标记为已读
  void markAllRead() {
    for (final m in messages) {
      m.read = true;
    }
    messages.refresh();
  }

  /// 清空消息
  void clear() {
    messages.clear();
  }
}
