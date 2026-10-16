import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/api/user.dart';
import 'package:hm_shop/pages/Cart/index.dart';
import 'package:hm_shop/pages/Category/index.dart';
import 'package:hm_shop/pages/Home/index.dart';
import 'package:hm_shop/pages/Messages/index.dart';
import 'package:hm_shop/pages/Mine/index.dart';
import 'package:hm_shop/stores/CartController.dart';
import 'package:hm_shop/stores/FavoriteController.dart';
import 'package:hm_shop/stores/FootprintController.dart';
import 'package:hm_shop/stores/MemberController.dart';
import 'package:hm_shop/stores/MessageController.dart';
import 'package:hm_shop/stores/OrderController.dart';
import 'package:hm_shop/stores/TokenManager.dart';
import 'package:hm_shop/stores/UserController.dart';
import 'package:hm_shop/services/NotificationService.dart';

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
      'icon': 'lib/assets/消息.png',
      'active_icon': 'lib/assets/消息激活.png',
      'text': '消息',
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
      // 消息 Tab（index 2）加未读徽标
      if (index == 2) {
        return BottomNavigationBarItem(
          icon: _buildMessageIcon(_tapList[index]['icon']!, false),
          activeIcon: _buildMessageIcon(_tapList[index]['active_icon']!, true),
          label: _tapList[index]['text']!,
        );
      }
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

  /// 消息 Tab 图标 + 未读徽标
  Widget _buildMessageIcon(String asset, bool active) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(asset, height: 30, width: 30),
          Positioned(
            right: -4,
            top: -4,
            child: Obx(() {
              final count = Get.find<MessageController>().unreadCount;
              if (count == 0) return SizedBox.shrink();
              return Container(
                constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                padding: EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFA6D6D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _getChildren() {
    return [
      HomePage(),
      CategoryPage(),
      MessagesPage(isTab: true),
      CartPage(),
      MinePage(),
    ];
  }

  // put只能由一次，find可以多次获取
  final UserController _userController = Get.put(UserController());

  /// 初始化用户信息
  void _userInit() async {
    await tokenManager.init();
    if (tokenManager.getToken().isNotEmpty) {
      try {
        _userController.updataUserInfo(await getUserProfile());
        // 后端无头像/nickname 字段，登录态下恢复本地设置项
        await _userController.loadLocalAvatar();
        await _userController.loadLocalNickname();
      } catch (_) {
        // token 失效或网络异常：静默保持未登录态
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 全局状态：购物车 + 收藏 + 订单 + 足迹 + 会员 + 消息（与 UserController 同样使用 Get.put 注册）
    Get.put(CartController());
    Get.put(FavoriteController());
    Get.put(OrderController());
    Get.put(FootprintController());
    Get.put(MemberController());
    Get.put(MessageController());
    _userInit();
    _initNotifications();
  }

  /// 初始化本地通知并请求弹窗权限
  void _initNotifications() async {
    await notificationService.init();
    await notificationService.requestPermission();
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
