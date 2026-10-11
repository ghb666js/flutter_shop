import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/index.dart';

Future<List<RecommendItem>> getRecommendData(Map<String, int> p) async {
  final res = await dioRequest.getRaw(HttpConstants.RECOMMEND_LIST, params: p);
  final products = (res as Map<String, dynamic>)['products'] as List;
  return products
      .map((item) => RecommendItem.fromJson(item as Map<String, dynamic>))
      .toList();
}
