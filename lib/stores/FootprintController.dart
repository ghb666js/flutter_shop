import 'package:get/get.dart';
import 'package:hm_shop/stores/UserController.dart';
import 'package:hm_shop/viewmodels/index.dart';

/// 浏览足迹：用户进入商品详情页即记录，仅登录态下记录。
class FootprintController extends GetxController {
  RxList<ItemsData> items = <ItemsData>[].obs;

  /// 记录浏览足迹：同 id 去重后插入头部，仅登录态记录
  void record(ItemsData p) {
    final logged = Get.find<UserController>().user.value.id.isNotEmpty;
    if (!logged) return;
    items.removeWhere((e) => e.id == p.id);
    items.insert(0, p);
  }

  void remove(String id) {
    items.removeWhere((e) => e.id == id);
  }

  void clear() {
    items.clear();
  }
}
