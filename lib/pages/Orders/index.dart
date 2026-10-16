import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/OrderController.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/order.dart';

class OrdersPage extends StatefulWidget {
  final String? statusFilter;

  OrdersPage({Key? key, this.statusFilter}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final OrderController _orderController;
  Timer? _ticker;

  final List<Map<String, dynamic>> _payments = [
    {'label': '微信支付', 'icon': Icons.chat_outlined, 'color': Color(0xFF07C160)},
    {
      'label': '支付宝支付',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFF1677FF),
    },
    {'label': '银行卡支付', 'icon': Icons.credit_card, 'color': Color(0xFFFF9500)},
  ];

  @override
  void initState() {
    super.initState();
    _orderController = Get.find<OrderController>();
    // 待付款页需要每秒刷新倒计时
    if (widget.statusFilter == '待付款') {
      _ticker = Timer.periodic(Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<Order> get _filteredOrders {
    if (widget.statusFilter == null || widget.statusFilter!.isEmpty) {
      return _orderController.orders.toList();
    }
    return _orderController.orders
        .where((o) => o.status == widget.statusFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(widget.statusFilter ?? '全部订单'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final list = _filteredOrders;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12),
                Text('暂无订单', style: TextStyle(color: _textSub, fontSize: 14)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(10),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(height: 10),
          itemBuilder: (context, index) => _buildOrderCard(list[index]),
        );
      }),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '订单号: ${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: _textSub),
                ),
              ),
              SizedBox(width: 8),
              Text(
                order.status,
                style: TextStyle(
                  fontSize: 13,
                  color: order.status == '待评价'
                      ? Color(0xFFFF9800)
                      : order.status == '已完成'
                      ? Color(0xFF4CAF50)
                      : order.status == '已取消'
                      ? Color(0xFF999999)
                      : _primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...order.items.map((e) => _buildProductRow(e)),
          Divider(height: 16),
          // 下单时间 / 支付方式 / 合计：用 Flexible 避免小屏溢出黄条
          Row(
            children: [
              Flexible(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '下单时间: ${_formatTime(order.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: _textSub),
                    ),
                    if (order.paymentMethod.isNotEmpty)
                      Text(
                        '  |  ${order.paymentMethod}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: _textSub),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text('合计: ', style: TextStyle(fontSize: 13, color: _textMain)),
              Text(
                '¥${order.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // 待付款：倒计时 + 去支付 / 取消订单
          if (order.status == '待付款') ...[
            SizedBox(height: 10),
            _buildPendingActions(order),
          ],
          // 待收货：确认收货
          if (order.status == '待收货') ...[
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(color: _primary),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _orderController.confirmReceipt(order.id);
                  ToastUtils.showToast(context, '已确认收货', showWith: 200);
                },
                child: Text('确认收货'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 待付款订单的操作行：倒计时 + 去支付 + 取消订单
  Widget _buildPendingActions(Order order) {
    final remain = order.remainingSeconds;
    final mm = (remain < 0 ? 0 : remain) ~/ 60;
    final ss = (remain < 0 ? 0 : remain) % 60;
    final countdown =
        '${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Text(
          '剩余 $countdown 自动取消',
          style: TextStyle(fontSize: 12, color: Color(0xFFFF9800)),
        ),
        Spacer(),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: _textSub,
            side: BorderSide(color: Color(0xFFE5E5E5)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            _orderController.cancelOrder(order.id);
            ToastUtils.showToast(context, '订单已取消', showWith: 200);
          },
          child: Text('取消订单'),
        ),
        SizedBox(width: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: _primary,
            side: BorderSide(color: _primary),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _showPaySheet(order),
          child: Text('去支付'),
        ),
      ],
    );
  }

  /// 支付方式底部弹层
  void _showPaySheet(Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '选择支付方式',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            for (int i = 0; i < _payments.length; i++)
              ListTile(
                leading: Icon(
                  _payments[i]['icon'] as IconData,
                  color: _payments[i]['color'] as Color,
                  size: 26,
                ),
                title: Text(_payments[i]['label'] as String),
                onTap: () {
                  final method = _payments[i]['label'] as String;
                  Navigator.pop(ctx);
                  _orderController.payOrder(order.id, method);
                  ToastUtils.showToast(context, '支付成功', showWith: 200);
                },
              ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(OrderProduct op) {
    final p = op.product;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              p.picture,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade100,
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: _textMain),
                ),
                SizedBox(height: 4),
                Text(
                  '¥${p.price} x${op.quantity}',
                  style: TextStyle(fontSize: 12, color: _textSub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/product', arguments: p);
            },
            child: Text(
              '再次购买',
              style: TextStyle(fontSize: 12, color: _primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}
