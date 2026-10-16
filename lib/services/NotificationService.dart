import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 本地通知服务：初始化、请求权限、发送通知
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 初始化通知插件
  Future<void> init() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (_) {},
      );

      _initialized = true;
    } catch (_) {
      // 初始化失败时静默处理，不影响 App 运行
    }
  }

  /// 请求通知权限（Android 13+ 需要）
  Future<bool> requestPermission() async {
    if (!_initialized) return false;

    try {
      // Android 13+ 需要运行时请求通知权限
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (_) {
      // 请求失败时静默处理
    }
    return false;
  }

  /// 发送一条本地通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'order_channel',
        '订单消息',
        channelDescription: '订单发货与物流消息通知',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(id, title, body, details);
    } catch (_) {
      // 发送失败时静默处理
    }
  }
}

final notificationService = NotificationService();
