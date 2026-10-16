import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/CartController.dart';
import 'package:hm_shop/stores/FavoriteController.dart';
import 'package:hm_shop/stores/FootprintController.dart';
import 'package:hm_shop/utils/LoginGuard.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/index.dart';

class ProductDetailPage extends StatefulWidget {
  final ItemsData product;
  ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late ItemsData _product;
  late final CartController _cartController;
  late final FavoriteController _favoriteController;
  late final FootprintController _footprintController;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _cartController = Get.find<CartController>();
    _favoriteController = Get.find<FavoriteController>();
    _footprintController = Get.find<FootprintController>();
    // 浏览即记录足迹（登录态下才记录）
    // 延迟到帧结束后执行：足迹页 Obx 正在监听 items，若在 build 阶段
    // 同步修改会触发 "setState/markNeedsBuild called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _footprintController.record(_product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品详情'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 浮在商品图右上角的醒目收藏按钮
  Widget _buildFloatingFavorite() {
    return Positioned(
      top: 16,
      right: 16,
      child: Obx(() {
        final liked = _favoriteController.isFavorite(_product.id);
        return Material(
          color: Colors.white.withOpacity(0.9),
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (!requireLogin(context)) return;
              _favoriteController.toggle(_product);
              ToastUtils.showToast(
                context,
                liked ? '已取消收藏' : '已收藏',
                showWith: 200,
              );
            },
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.red : _primary,
                size: 24,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  _product.picture,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 64,
                    ),
                  ),
                ),
              ),
              _buildFloatingFavorite(),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¥${_product.price}',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textMain,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _product.desc.isEmpty ? '暂无描述' : _product.desc,
                  style: TextStyle(fontSize: 14, color: _textSub),
                ),
                SizedBox(height: 8),
                if (_product.orderNum.isNotEmpty)
                  Text(
                    '已售 ${_product.orderNum}',
                    style: TextStyle(fontSize: 12, color: _textSub),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(color: _primary),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  if (!requireLogin(context)) return;
                  _cartController.addItem(_product);
                  ToastUtils.showToast(context, '已加入购物车', showWith: 200);
                },
                child: Text('加入购物车'),
              ),
            ),
            SizedBox(width: 12),
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
                onPressed: () {
                  if (!requireLogin(context)) return;
                  Navigator.pushNamed(
                    context,
                    '/checkout',
                    arguments: {
                      'products': [_product],
                    },
                  );
                },
                child: Text('立即购买'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
