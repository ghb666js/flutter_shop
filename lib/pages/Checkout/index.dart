import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/CartController.dart';
import 'package:hm_shop/stores/OrderController.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/cart.dart';
import 'package:hm_shop/viewmodels/index.dart';

class CheckoutPage extends StatefulWidget {
  final List<ItemsData> products;
  final List<int> quantities;
  final bool fromCart;
  final List<String> cartItemIds;

  CheckoutPage({
    Key? key,
    required this.products,
    this.quantities = const [],
    this.fromCart = false,
    this.cartItemIds = const [],
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final OrderController _orderController;
  int _selectedPayment = 0; // 0=微信 1=支付宝 2=银行卡
  // 进入确认页即生成「待付款」订单，未支付返回则留在待付款列表（10 分钟自动取消）
  late final String _pendingOrderId;

  final List<Map<String, dynamic>> _payments = [
    {'label': '微信支付', 'icon': Icons.chat_outlined, 'color': Color(0xFF07C160)},
    {
      'label': '支付宝支付',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFF1677FF),
    },
    {'label': '银行卡支付', 'icon': Icons.credit_card, 'color': Color(0xFFFF9500)},
  ];

  double get _totalPrice {
    double total = 0;
    for (int i = 0; i < widget.products.length; i++) {
      final price = double.tryParse(widget.products[i].price) ?? 0;
      final qty = widget.quantities.isNotEmpty ? widget.quantities[i] : 1;
      total += price * qty;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _orderController = Get.find<OrderController>();
    // 创建待付款订单
    if (widget.fromCart) {
      final cartItems = <CartItem>[];
      for (int i = 0; i < widget.products.length; i++) {
        cartItems.add(
          CartItem(
            product: widget.products[i],
            quantity: widget.quantities.isNotEmpty ? widget.quantities[i] : 1,
          ),
        );
      }
      _pendingOrderId = _orderController.placePendingOrderFromCart(cartItems);
    } else {
      final qty = widget.quantities.isNotEmpty ? widget.quantities[0] : 1;
      _pendingOrderId = _orderController.placePendingOrder(
        widget.products[0],
        quantity: qty,
      );
    }
  }

  void _pay() {
    final method = _payments[_selectedPayment]['label'] as String;
    final ok = _orderController.payOrder(_pendingOrderId, method);
    if (!ok) {
      ToastUtils.showToast(context, '订单已失效', showWith: 200);
      return;
    }
    // 从购物车下单：清空已购买的购物车商品
    if (widget.fromCart && widget.cartItemIds.isNotEmpty) {
      try {
        Get.find<CartController>().removeItems(widget.cartItemIds);
      } catch (_) {}
    }

    ToastUtils.showToast(context, '支付成功', showWith: 200);

    // 跳转到订单页（待发货）
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/orders',
      (route) => route.settings.name == '/',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('确认订单'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 商品列表
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                _buildProductSection(),
                SizedBox(height: 10),
                _buildPaymentSection(),
              ],
            ),
          ),
          // 底部支付栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// 商品列表区域
  Widget _buildProductSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品信息',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
          SizedBox(height: 10),
          for (int i = 0; i < widget.products.length; i++)
            _buildProductRow(
              widget.products[i],
              widget.quantities.isNotEmpty ? widget.quantities[i] : 1,
            ),
          Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('合计: ', style: TextStyle(fontSize: 13, color: _textMain)),
              Text(
                '¥${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(ItemsData product, int quantity) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              product.picture,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
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
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: _textMain),
                ),
                SizedBox(height: 4),
                Text(
                  '¥${product.price} x$quantity',
                  style: TextStyle(fontSize: 12, color: _textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 支付方式区域
  Widget _buildPaymentSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付方式',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
          SizedBox(height: 10),
          for (int i = 0; i < _payments.length; i++) _buildPaymentItem(i),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(int index) {
    final p = _payments[index];
    final selected = _selectedPayment == index;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(p['icon'] as IconData, color: p['color'] as Color, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                p['label'] as String,
                style: TextStyle(fontSize: 14, color: _textMain),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _primary : _textSub,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  /// 底部支付栏
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('需支付', style: TextStyle(fontSize: 12, color: _textSub)),
                  Text(
                    '¥${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _pay,
                child: Text('立即支付'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
