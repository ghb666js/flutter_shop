import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/index.dart';

Future<List<CategoryItem>> getCategoryList() async {
  return ((await dioRequest.get(HttpConstants.CATEGORY_LIST)) as List)
      .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// 分类页左侧分类列表（中文标签 → dummyjson 分类 slug）
const List<Map<String, String>> categoryTabs = [
  {'label': '男装', 'slug': 'mens-shirts'},
  {'label': '女装', 'slug': 'womens-dresses'},
  {'label': '家居', 'slug': 'home-decoration'},
  {'label': '电子', 'slug': 'smartphones'},
  {'label': '运动', 'slug': 'motorcycle'},
  {'label': '食品', 'slug': 'groceries'},
  {'label': '汽车', 'slug': 'automotive'},
  {'label': '彩电', 'slug': 'lighting'},
  {'label': '生活', 'slug': 'furniture'},
  {'label': '儿童', 'slug': 'skincare'},
  {'label': '娱乐', 'slug': 'sunglasses'},
];

/// 按 dummyjson 分类 slug 获取商品列表，转为 ItemsData
Future<List<ItemsData>> getCategoryProducts(String slug) async {
  final res = await dioRequest.getRaw(
    'https://dummyjson.com/products/category/$slug',
    params: {'limit': 20, 'skip': 0},
  );
  final products = (res as Map<String, dynamic>)['products'] as List;
  return products.map((item) {
    final m = item as Map<String, dynamic>;
    return ItemsData(
      id: m['id']?.toString() ?? '',
      name: m['title']?.toString() ?? '',
      desc: m['description']?.toString() ?? '',
      price: m['price']?.toString() ?? '0',
      picture: m['thumbnail']?.toString() ?? '',
      orderNum: (m['stock'] as int?)?.toString() ?? '0',
    );
  }).toList();
}
