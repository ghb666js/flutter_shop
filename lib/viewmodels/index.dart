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
