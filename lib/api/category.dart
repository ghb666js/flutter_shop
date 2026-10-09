import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/index.dart';

Future<List<CategoryItem>> getCategoryList() async {
  return ((await dioRequest.get(HttpConstants.CATEGORY_LIST)) as List)
      .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
      .toList();
}
