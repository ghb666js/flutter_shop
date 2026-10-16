import 'package:get/get.dart';
import 'package:hm_shop/viewmodels/cart.dart';
import 'package:hm_shop/viewmodels/index.dart';

class CartController extends GetxController {
  RxList<CartItem> items = <CartItem>[].obs;
  RxList<String> selectedIds = <String>[].obs;

  void addItem(ItemsData product) {
    final idx = items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
  }

  void removeItem(String id) {
    items.removeWhere((e) => e.product.id == id);
    selectedIds.remove(id);
  }

  void removeItems(List<String> ids) {
    items.removeWhere((e) => ids.contains(e.product.id));
    selectedIds.removeWhere((id) => ids.contains(id));
  }

  void updateQty(String id, int qty) {
    if (qty <= 0) {
      removeItem(id);
      return;
    }
    final idx = items.indexWhere((e) => e.product.id == id);
    if (idx >= 0) {
      items[idx].quantity = qty;
      items.refresh();
    }
  }

  void clear() {
    items.clear();
    selectedIds.clear();
  }

  bool isSelected(String id) => selectedIds.contains(id);

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll(bool selected) {
    if (selected) {
      selectedIds.value = items.map((e) => e.product.id).toList();
    } else {
      selectedIds.clear();
    }
  }

  bool get isAllSelected =>
      items.isNotEmpty && selectedIds.length == items.length;

  double get total {
    double sum = 0;
    for (final e in items) {
      if (selectedIds.contains(e.product.id)) {
        final price = double.tryParse(e.product.price) ?? 0;
        sum += price * e.quantity;
      }
    }
    return sum;
  }
}
