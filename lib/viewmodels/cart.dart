import 'package:hm_shop/viewmodels/index.dart';

class CartItem {
  final ItemsData product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({ItemsData? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
