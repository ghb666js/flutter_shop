import 'package:flutter/material.dart';
import 'package:hm_shop/pages/Cart/index.dart';
import 'package:hm_shop/pages/Category/index.dart';
import 'package:hm_shop/pages/Home/index.dart';
import 'package:hm_shop/pages/Mine/index.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  final List<Map<String, String>> _tapList = [
    {
      'icon': 'lib/assets/首页.png',
      'active_icon': 'lib/assets/首页激活.png',
      'text': '首页',
    },
    {
      'icon': 'lib/assets/分类.png',
      'active_icon': 'lib/assets/分类激活.png',
      'text': '分类',
    },
    {
      'icon': 'lib/assets/购物车.png',
      'active_icon': 'lib/assets/购物车激活.png',
      'text': '购物车',
    },
    {
      'icon': 'lib/assets/我的.png',
      'active_icon': 'lib/assets/我的激活.png',
      'text': '我的',
    },
  ];
  int _currentIndex = 0;
  List<BottomNavigationBarItem> _getBottom() {
    return List.generate(_tapList.length, (index) {
      return BottomNavigationBarItem(
        icon: Image.asset(_tapList[index]['icon']!, height: 30, width: 30),

        activeIcon: Image.asset(
          _tapList[index]['active_icon']!,
          height: 30,
          width: 30,
        ),
        label: _tapList[index]['text']!,
      );
    });
  }

  List<Widget> _getChildren() {
    return [HomePage(), CategoryPage(), CartPage(), MinePage()];
  }

  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        // appBar: AppBar(title: Text('主页面'), centerTitle: true),
        body: SafeArea(
          child: IndexedStack(index: _currentIndex, children: _getChildren()),
        ),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          onTap: (index) {
            _currentIndex = index;
            setState(() {});
          },
          items: _getBottom(),
          currentIndex: _currentIndex,
        ),
      ),
    );
  }
}
