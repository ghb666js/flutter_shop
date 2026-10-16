import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/FootprintController.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/index.dart';

class FootprintPage extends StatefulWidget {
  FootprintPage({Key? key}) : super(key: key);

  @override
  _FootprintPageState createState() => _FootprintPageState();
}

class _FootprintPageState extends State<FootprintPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final FootprintController _footprintController;

  @override
  void initState() {
    super.initState();
    _footprintController = Get.find<FootprintController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('我的足迹'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(
            () => _footprintController.items.isEmpty
                ? SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      _footprintController.clear();
                      ToastUtils.showToast(context, '已清空足迹', showWith: 200);
                    },
                    child: Text('清空', style: TextStyle(color: Colors.white)),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final list = _footprintController.items;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12),
                Text('暂无浏览记录', style: TextStyle(color: _textSub, fontSize: 14)),
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
            icon: Icon(Icons.close, color: Colors.grey),
            tooltip: '删除',
            onPressed: () {
              _footprintController.remove(item.id);
              ToastUtils.showToast(context, '已删除', showWith: 200);
            },
          ),
        ],
      ),
    );
  }
}
