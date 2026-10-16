import 'package:get/get.dart';
import 'package:hm_shop/viewmodels/index.dart';

class FavoriteController extends GetxController {
  RxList<ItemsData> items = <ItemsData>[].obs;

  bool isFavorite(String id) => items.any((e) => e.id == id);

  void toggle(ItemsData p) {
    if (isFavorite(p.id)) {
      items.removeWhere((e) => e.id == p.id);
    } else {
      items.add(p);
    }
  }

  void remove(String id) {
    items.removeWhere((e) => e.id == id);
  }
}
