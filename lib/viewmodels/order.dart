import 'package:hm_shop/viewmodels/index.dart';

/// 订单中的商品行（商品 + 数量）
class OrderProduct {
  final ItemsData product;
  int quantity;
  OrderProduct({required this.product, this.quantity = 1});
}

/// 一笔订单
class Order {
  final String id;
  final List<OrderProduct> items;
  final double totalPrice;
  final DateTime createdAt;
  // 待付款 / 待发货 / 待收货 / 待评价 / 已完成 / 已取消
  String status;
  // 微信支付 / 支付宝支付 / 银行卡支付
  String paymentMethod;
  // 待付款订单的自动取消截止时间（支付或取消后置空）
  DateTime? expireAt;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = '待发货',
    this.paymentMethod = '',
    this.expireAt,
  });

  /// 待付款剩余秒数（<=0 表示已过期）
  int get remainingSeconds {
    if (expireAt == null) return 0;
    return expireAt!.difference(DateTime.now()).inSeconds;
  }
}
