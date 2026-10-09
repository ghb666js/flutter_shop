import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/index.dart';

Future<List<BannerItem>> getBannerItem() async {
  return ((await dioRequest.get(HttpConstants.BANNER_LIST)) as List)
      .map((item) => BannerItem.fromJson(item))
      .toList();
}
