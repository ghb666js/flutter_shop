import 'package:flutter/material.dart';
import 'package:hm_shop/pages/Checkout/index.dart';
import 'package:hm_shop/pages/Favorite/index.dart';
import 'package:hm_shop/pages/Footprint/index.dart';
import 'package:hm_shop/pages/Login/index.dart';
import 'package:hm_shop/pages/Main/index.dart';
import 'package:hm_shop/pages/Member/index.dart';
import 'package:hm_shop/pages/Messages/index.dart';
import 'package:hm_shop/pages/Orders/index.dart';
import 'package:hm_shop/pages/ProductDetail/index.dart';
import 'package:hm_shop/pages/Search/index.dart';
import 'package:hm_shop/viewmodels/index.dart';

Widget getRootWight() {
  return MaterialApp(initialRoute: '/', routes: getRootRoutes());
}

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    '/': (context) => MainPage(),
    '/login': (context) => LoginPage(),
    '/product': (context) => ProductDetailPage(
      product: ModalRoute.of(context)!.settings.arguments as ItemsData,
    ),
    '/checkout': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return CheckoutPage(
        products: args['products'] as List<ItemsData>,
        quantities: args['quantities'] as List<int>? ?? const [],
        fromCart: args['fromCart'] as bool? ?? false,
        cartItemIds: args['cartItemIds'] as List<String>? ?? const [],
      );
    },
    '/favorite': (context) => FavoritePage(),
    '/footprint': (context) => FootprintPage(),
    '/member': (context) => MemberPage(),
    '/messages': (context) => MessagesPage(),
    '/orders': (context) => OrdersPage(
      statusFilter: ModalRoute.of(context)!.settings.arguments as String?,
    ),
    '/search': (context) => SearchPage(),
  };
}
