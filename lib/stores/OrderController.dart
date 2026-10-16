import 'dart:async';

import 'package:get/get.dart';
import 'package:hm_shop/stores/MessageController.dart';
import 'package:hm_shop/viewmodels/cart.dart';
import 'package:hm_shop/viewmodels/index.dart';
import 'package:hm_shop/viewmodels/order.dart';

class OrderController extends GetxController {
  RxList<Order> orders = <Order>[].obs;

  /// 按订单 id 保存其定时器（自动取消 / 自动发货 / 自动到达）
  final Map<String, List<Timer>> _timersByOrder = {};

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString();

  /// 获取 MessageController（延迟获取，避免初始化顺序问题）
  MessageController get _messageController {
    try {
      return Get.find<MessageController>();
    } catch (_) {
      return Get.put(MessageController());
    }
  }

  void _addTimer(String orderId, Timer t) {
    (_timersByOrder[orderId] ??= []).add(t);
  }

  void _cancelTimers(String orderId) {
    final list = _timersByOrder.remove(orderId);
    if (list != null) {
      for (final t in list) {
        t.cancel();
      }
    }
  }

  /// 单品立即购买：创建「待付款」订单，10 分钟内未支付自动取消
  String placePendingOrder(ItemsData product, {int quantity = 1}) {
    final price = double.tryParse(product.price) ?? 0;
    final order = Order(
      id: _genId(),
      items: [OrderProduct(product: product, quantity: quantity)],
      totalPrice: price * quantity,
      createdAt: DateTime.now(),
      status: '待付款',
      expireAt: DateTime.now().add(Duration(minutes: 10)),
    );
    orders.insert(0, order);
    _scheduleAutoCancel(order);
    return order.id;
  }

  /// 从购物车选中商品下单：创建「待付款」订单
  String placePendingOrderFromCart(List<CartItem> cartItems) {
    if (cartItems.isEmpty) return '';
    double total = 0;
    for (final c in cartItems) {
      final price = double.tryParse(c.product.price) ?? 0;
      total += price * c.quantity;
    }
    final order = Order(
      id: _genId(),
      items: cartItems
          .map((c) => OrderProduct(product: c.product, quantity: c.quantity))
          .toList(),
      totalPrice: total,
      createdAt: DateTime.now(),
      status: '待付款',
      expireAt: DateTime.now().add(Duration(minutes: 10)),
    );
    orders.insert(0, order);
    _scheduleAutoCancel(order);
    return order.id;
  }

  /// 待付款倒计时到期 → 自动取消
  void _scheduleAutoCancel(Order order) {
    final delay = order.expireAt!.difference(DateTime.now());
    final t = Timer(delay.isNegative ? Duration.zero : delay, () {
      final idx = _indexOf(order.id);
      if (idx >= 0 && orders[idx].status == '待付款') {
        orders[idx].status = '已取消';
        orders[idx].expireAt = null;
        _cancelTimers(order.id);
        orders.refresh();
        final productName = orders[idx].items.isNotEmpty
            ? orders[idx].items.first.product.name
            : '商品';
        _messageController.addMessage('订单取消', '您的订单「$productName」因超时未支付已自动取消。');
      }
    });
    _addTimer(order.id, t);
  }

  /// 支付待付款订单：待付款 → 待发货，并启动后续自动发货/到达流程
  bool payOrder(String orderId, String paymentMethod) {
    final idx = _indexOf(orderId);
    if (idx < 0 || orders[idx].status != '待付款') return false;
    final o = orders[idx];
    o.status = '待发货';
    o.paymentMethod = paymentMethod;
    o.expireAt = null;
    _cancelTimers(orderId);
    _scheduleAutoProgress(o);
    orders.refresh();
    final productName = o.items.isNotEmpty ? o.items.first.product.name : '商品';
    _messageController.addMessage('支付成功', '您的订单「$productName」已支付，正在等待发货。');
    return true;
  }

  /// 手动取消待付款订单
  bool cancelOrder(String orderId) {
    final idx = _indexOf(orderId);
    if (idx < 0 || orders[idx].status != '待付款') return false;
    orders[idx].status = '已取消';
    orders[idx].expireAt = null;
    _cancelTimers(orderId);
    orders.refresh();
    return true;
  }

  int _indexOf(String id) {
    for (int i = 0; i < orders.length; i++) {
      if (orders[i].id == id) return i;
    }
    return -1;
  }

  /// 定时自动推进订单状态：
  /// 支付后 1 分钟 → 待收货（已发货）
  /// 再 1 分钟后 → 待评价（已到达）
  void _scheduleAutoProgress(Order order) {
    final orderIndex = () => _indexOf(order.id);

    // 1 分钟后自动发货
    final shipTimer = Timer(Duration(minutes: 1), () {
      final idx = orderIndex();
      if (idx >= 0 && orders[idx].status == '待发货') {
        final o = orders[idx];
        o.status = '待收货';
        orders.refresh();
        final productName = o.items.isNotEmpty
            ? o.items.first.product.name
            : '商品';
        _messageController.addMessage('发货通知', '您的订单「$productName」已发货，请注意查收。');
      }
    });
    _addTimer(order.id, shipTimer);

    // 2 分钟后自动到达
    final arriveTimer = Timer(Duration(minutes: 2), () {
      final idx = orderIndex();
      if (idx >= 0 && orders[idx].status == '待收货') {
        final o = orders[idx];
        o.status = '待评价';
        orders.refresh();
        final productName = o.items.isNotEmpty
            ? o.items.first.product.name
            : '商品';
        _messageController.addMessage('到达通知', '您的订单「$productName」已送达，请确认收货。');
      }
    });
    _addTimer(order.id, arriveTimer);
  }

  /// 确认收货：待收货 → 待评价
  void confirmReceipt(String orderId) {
    for (int i = 0; i < orders.length; i++) {
      if (orders[i].id == orderId && orders[i].status == '待收货') {
        orders[i].status = '待评价';
        orders.refresh();
        final productName = orders[i].items.isNotEmpty
            ? orders[i].items.first.product.name
            : '商品';
        _messageController.addMessage('收货确认', '您已确认收货「$productName」，欢迎评价分享。');
        break;
      }
    }
  }

  int get count => orders.length;

  @override
  void onClose() {
    for (final list in _timersByOrder.values) {
      for (final t in list) {
        t.cancel();
      }
    }
    _timersByOrder.clear();
    super.onClose();
  }
}
