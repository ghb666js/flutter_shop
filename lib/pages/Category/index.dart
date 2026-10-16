import 'package:flutter/material.dart';
import 'package:hm_shop/api/category.dart';
import 'package:hm_shop/viewmodels/index.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  int _selectedIndex = 0;
  List<ItemsData> _products = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final slug = categoryTabs[_selectedIndex]['slug']!;
      _products = await getCategoryProducts(slug);
    } catch (_) {
      _products = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onCategoryTap(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('分类'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // 左侧分类栏
          _buildLeftBar(),
          // 右侧商品列表
          Expanded(child: _buildRightPanel()),
        ],
      ),
    );
  }

  /// 左侧分类选择栏
  Widget _buildLeftBar() {
    return Container(
      width: 84,
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: categoryTabs.length,
        itemBuilder: (context, index) {
          final selected = index == _selectedIndex;
          return GestureDetector(
            onTap: () => _onCategoryTap(index),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Color(0xFFF6F6F6) : Colors.white,
                border: Border(
                  left: BorderSide(
                    color: selected ? _primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                categoryTabs[index]['label']!,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? _primary : _textMain,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 右侧商品网格
  Widget _buildRightPanel() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 12),
            Text('暂无商品', style: TextStyle(color: _textSub, fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) => _buildProductCard(_products[index]),
    );
  }

  /// 商品卡片：上图 + 下名+价
  Widget _buildProductCard(ItemsData item) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/product', arguments: item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图
            Expanded(
              child: Image.network(
                item.picture,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
            // 商品信息
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: _textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '¥${item.price}',
                    style: TextStyle(
                      fontSize: 15,
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
    );
  }
}
