import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/CartController.dart';
import 'package:hm_shop/utils/LoginGuard.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/cart.dart';

class CartPage extends StatefulWidget {
  CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final CartController _cartController;

  @override
  void initState() {
    super.initState();
    _cartController = Get.find<CartController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('购物车'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (_cartController.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12),
                Text('购物车是空的', style: TextStyle(color: _textSub, fontSize: 14)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(10),
          itemCount: _cartController.items.length,
          separatorBuilder: (_, __) => SizedBox(height: 10),
          itemBuilder: (context, index) =>
              _buildCartItem(_cartController.items[index]),
        );
      }),
      bottomNavigationBar: Obx(() => _buildBottomBar()),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final id = item.product.id;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Obx(() {
            return Checkbox(
              value: _cartController.isSelected(id),
              onChanged: (_) => _cartController.toggleSelect(id),
              activeColor: _primary,
            );
          }),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.picture,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
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
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: _textMain),
                ),
                SizedBox(height: 6),
                Text(
                  '¥${item.product.price}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                _buildQtyStepper(item),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: _textSub),
            onPressed: () {
              _cartController.removeItem(id);
              ToastUtils.showToast(context, '已删除', showWith: 160);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQtyStepper(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyBtn(Icons.remove, () {
          _cartController.updateQty(item.product.id, item.quantity - 1);
        }),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${item.quantity}',
            style: TextStyle(fontSize: 14, color: _textMain),
          ),
        ),
        _qtyBtn(Icons.add, () {
          _cartController.updateQty(item.product.id, item.quantity + 1);
        }),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: _textMain),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_cartController.items.isEmpty) return SizedBox.shrink();
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Obx(() {
              return Checkbox(
                value: _cartController.isAllSelected,
                onChanged: (v) => _cartController.selectAll(v ?? false),
                activeColor: _primary,
              );
            }),
            Text('全选', style: TextStyle(fontSize: 14, color: _textMain)),
            SizedBox(width: 12),
            Text('合计: ', style: TextStyle(fontSize: 14, color: _textMain)),
            Obx(() {
              return Text(
                '¥${_cartController.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            Spacer(),
            _actionBtn('删除', Colors.white, _primary, _primary, () {
              if (_cartController.selectedIds.isEmpty) {
                ToastUtils.showToast(context, '请选择要删除的商品', showWith: 220);
                return;
              }
              final ids = _cartController.selectedIds.toList();
              _cartController.removeItems(ids);
              ToastUtils.showToast(context, '已删除', showWith: 160);
            }),
            SizedBox(width: 8),
            _actionBtn('购买', _primary, Colors.white, _primary, () {
              if (!requireLogin(context)) return;
              if (_cartController.selectedIds.isEmpty) {
                ToastUtils.showToast(context, '请选择要购买的商品', showWith: 220);
                return;
              }
              // 取出选中的购物车商品跳转到下单页
              final selected = _cartController.items
                  .where((e) => _cartController.isSelected(e.product.id))
                  .toList();
              Navigator.pushNamed(
                context,
                '/checkout',
                arguments: {
                  'products': selected.map((e) => e.product).toList(),
                  'quantities': selected.map((e) => e.quantity).toList(),
                  'fromCart': true,
                  'cartItemIds': selected.map((e) => e.product.id).toList(),
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    Color bg,
    Color fg,
    Color border,
    VoidCallback onTap,
  ) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Text(label, style: TextStyle(fontSize: 14, color: fg)),
        ),
      ),
    );
  }
}
