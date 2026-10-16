import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/MessageController.dart';
import 'package:hm_shop/viewmodels/message.dart';

class MessagesPage extends StatefulWidget {
  final bool isTab;
  MessagesPage({Key? key, this.isTab = false}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final MessageController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = Get.find<MessageController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('系统消息'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          Obx(
            () => _messageController.messages.isEmpty
                ? SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      _messageController.markAllRead();
                    },
                    child: Text('全部已读', style: TextStyle(color: Colors.white)),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final list = _messageController.messages;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12),
                Text('暂无消息', style: TextStyle(color: _textSub, fontSize: 14)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(10),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemBuilder: (context, index) => _buildMessageCard(list[index]),
        );
      }),
    );
  }

  Widget _buildMessageCard(AppMessage msg) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: msg.read
            ? null
            : Border.all(color: _primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications, color: _primary, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        msg.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _textMain,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(msg.time),
                      style: TextStyle(fontSize: 11, color: _textSub),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  msg.content,
                  style: TextStyle(fontSize: 13, color: _textSub),
                ),
              ],
            ),
          ),
          if (!msg.read)
            Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}
