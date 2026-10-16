/// 系统消息模型
class AppMessage {
  final String id;
  final String title;
  final String content;
  final DateTime time;
  bool read;

  AppMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.read = false,
  });
}
