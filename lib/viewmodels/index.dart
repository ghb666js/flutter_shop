import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';

class BannerItem {
  String id;
  String imageUrl;
  BannerItem({required this.id, required this.imageUrl});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(id: json['id'] ?? '', imageUrl: json['imgUrl'] ?? '');
  }
}

// 拓展一个工厂函数，用factory声明，一般用来创建实例对象
class CategoryItem {
  String id;
  String name;
  String picture;
  List<CategoryItem>? children;

  CategoryItem({
    required this.id,
    required this.name,
    required this.picture,
    this.children,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      picture: json['picture'] ?? '',
      children: (json['children'] as List?)
          ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 单个商品
class GoodsItem {
  String id;
  String name;
  String? desc;
  String price;
  String picture;
  int orderNum;

  GoodsItem({
    required this.id,
    required this.name,
    this.desc,
    required this.price,
    required this.picture,
    required this.orderNum,
  });

  factory GoodsItem.fromJson(Map<String, dynamic> json) {
    return GoodsItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] as String?,
      price: json['price']?.toString() ?? '0',
      picture: json['picture'] ?? '',
      orderNum: json['orderNum'] as int? ?? 0,
    );
  }
}

/// 分页商品列表
class SubTypeGoodsItems {
  int counts;
  int pageSize;
  int pages;
  int page;
  List<GoodsItem> items;

  SubTypeGoodsItems({
    required this.counts,
    required this.pageSize,
    required this.pages,
    required this.page,
    required this.items,
  });

  factory SubTypeGoodsItems.fromJson(Map<String, dynamic> json) {
    return SubTypeGoodsItems(
      counts: json['counts'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      items:
          (json['items'] as List?)
              ?.map((e) => GoodsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 推荐子分类（如 "抢先尝鲜" / "新品预告"）
class SubTypeItem {
  String id;
  String title;
  SubTypeGoodsItems goodsItems;

  SubTypeItem({
    required this.id,
    required this.title,
    required this.goodsItems,
  });

  factory SubTypeItem.fromJson(Map<String, dynamic> json) {
    return SubTypeItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      goodsItems: SubTypeGoodsItems.fromJson(
        json['goodsItems'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// 推荐商品（首页推荐模块）
class RecommendItem {
  String id;
  String name;
  String price;
  String picture;
  int payCount;

  RecommendItem({
    required this.id,
    required this.name,
    required this.price,
    required this.picture,
    required this.payCount,
  });

  factory RecommendItem.fromJson(Map<String, dynamic> json) {
    return RecommendItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? '',
      price: json['price']?.toString() ?? '0',
      picture: json['picture'] ?? json['thumbnail'] ?? '',
      payCount: json['payCount'] as int? ?? 0,
    );
  }
}

/// 推荐区块整体
class SuggestionData {
  String id;
  String title;
  List<SubTypeItem> subTypes;

  SuggestionData({
    required this.id,
    required this.title,
    required this.subTypes,
  });

  factory SuggestionData.fromJson(Map<String, dynamic> json) {
    return SuggestionData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subTypes:
          (json['subTypes'] as List?)
              ?.map((e) => SubTypeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GuessLikeData {
  int counts;
  int pageSize;
  int pages;
  int page;
  List<ItemsData> itemsData;
  GuessLikeData({
    required this.counts,
    required this.pageSize,
    required this.pages,
    required this.page,
    required this.itemsData,
  });

  factory GuessLikeData.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return GuessLikeData(
      counts: json['counts'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      itemsData: items
          .map((e) => ItemsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ItemsData {
  String id;
  String name;
  String desc;
  String price;
  String picture;
  String orderNum;
  ItemsData({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.picture,
    required this.orderNum,
  });

  factory ItemsData.fromJson(Map<String, dynamic> json) {
    return ItemsData(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      picture: json['picture']?.toString() ?? '',
      orderNum: json['orderNum']?.toString() ?? '0',
    );
  }
}
