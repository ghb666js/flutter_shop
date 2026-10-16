import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/FavoriteController.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/index.dart';

class FavoritePage extends StatefulWidget {
  FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final FavoriteController _favoriteController;

  @override
  void initState() {
    super.initState();
    _favoriteController = Get.find<FavoriteController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('我的收藏'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final list = _favoriteController.items;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12),
                Text('暂无收藏', style: TextStyle(color: _textSub, fontSize: 14)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(10),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(height: 10),
          itemBuilder: (context, index) => _buildItem(list[index]),
        );
      }),
    );
  }

  Widget _buildItem(ItemsData item) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () =>
                  Navigator.pushNamed(context, '/product', arguments: item),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.picture,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: _textMain),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '¥${item.price}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            tooltip: '取消收藏',
            onPressed: () {
              _favoriteController.remove(item.id);
              ToastUtils.showToast(context, '已取消收藏', showWith: 200);
            },
          ),
        ],
      ),
    );
  }
}
