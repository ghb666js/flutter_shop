import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:hm_shop/api/guessLike.dart';
import 'package:hm_shop/api/user.dart';
import 'package:hm_shop/components/Mine/HmGuess.dart';
import 'package:hm_shop/stores/MemberController.dart';
import 'package:hm_shop/stores/TokenManager.dart';
import 'package:hm_shop/stores/UserController.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/index.dart';
import 'package:hm_shop/viewmodels/users.dart';
import 'package:image_picker/image_picker.dart';

class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  // 主题色
  static const Color _primary = Color(0xFFFA6D6D); // 珊瑚粉
  static const Color _accent = Color(0xFF6B2737); // 深栗
  static const Color _pageBg = Color(0xFFF6F6F6); // 页面背景
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF666666);
  final UserController _userController = Get.find();
  final MemberController _memberController = Get.find();
  // 猜你喜欢状态
  final ScrollController _scrollController = ScrollController();
  final List<ItemsData> _guessList = [];
  int _guessPage = 1;
  bool _guessLoading = false;
  bool _guessHasMore = true;

  @override
  void initState() {
    super.initState();
    _loadGuess();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动接近底部时加载下一页
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadGuess();
    }
  }

  /// 加载猜你喜欢（分页，每次 8 条）
  Future<void> _loadGuess() async {
    if (_guessLoading || !_guessHasMore) return;
    setState(() => _guessLoading = true);
    try {
      final data = await getGuessLikeData({'page': _guessPage, 'pageSize': 8});
      _guessList.addAll(data.itemsData);
      // 利用接口分页数据：当前页 < 总页数，说明还有下一页
      _guessHasMore = _guessPage < data.pages;
      _guessPage++;
    } catch (_) {
      // 加载失败保留已有数据，下次滚动/刷新重试
    } finally {
      if (mounted) setState(() => _guessLoading = false);
    }
  }

  /// 下拉刷新：重置回第 1 页
  Future<void> _onRefresh() async {
    setState(() {
      _guessPage = 1;
      _guessHasMore = true;
      _guessList.clear();
    });
    await _loadGuess();
  }

  /// 头像图片提供者：http 链接 → NetworkImage；本地路径 → FileImage；空 → null
  ImageProvider? _avatarProvider(UserInfo user) {
    final a = user.avatar;
    if (a.isEmpty) return null;
    if (a.startsWith('http')) return NetworkImage(a);
    return FileImage(File(a));
  }

  /// 头像选择底部弹层（相册 / 拍照）
  void _showAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_outlined, color: _primary),
              title: Text('从相册选择'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: _primary),
              title: Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.close, color: Colors.grey),
              title: Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  /// 调用 image_picker 选图并本地持久化头像
  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (xfile == null) return;
      await _userController.updateAvatar(xfile.path);
      if (mounted) ToastUtils.showToast(context, '头像已更新');
    } catch (_) {
      if (mounted) ToastUtils.showToast(context, '设置头像失败', showWith: 240);
    }
  }

  /// 修改昵称弹窗
  void _showNicknameDialog() {
    final ctrl = TextEditingController(
      text: _userController.user.value.nickname,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('修改昵称'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 12,
          decoration: InputDecoration(
            hintText: '请输入昵称',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              Navigator.pop(ctx);
              if (name.isEmpty) {
                ToastUtils.showToast(context, '昵称不能为空', showWith: 240);
                return;
              }
              await _userController.updateNickname(name);
              if (mounted) ToastUtils.showToast(context, '昵称已更新');
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _pageBg,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverToBoxAdapter(child: _buildVipBanner()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildOrderSection()),
            SliverPersistentHeader(delegate: HmGuess(), pinned: true),
            _buildGuessGrid(),
            _buildGuessFooter(),
          ],
        ),
      ),
    );
  }

  /// 猜你喜欢商品网格
  Widget _buildGuessGrid() {
    // 首次加载中
    if (_guessList.isEmpty && _guessLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }
    // 无数据
    if (_guessList.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(height: 200, child: Center(child: Text('暂无数据'))),
      );
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: _guessList.length,
      itemBuilder: (BuildContext context, int index) =>
          _buildGoodsCard(_guessList[index]),
    );
  }

  /// 单个商品卡片
  Widget _buildGoodsCard(ItemsData item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/product', arguments: item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                item.picture,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: _textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '¥${item.price}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 列表底部：加载中 / 没有更多
  Widget _buildGuessFooter() {
    if (_guessList.isEmpty) return SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: !_guessHasMore
              ? Text('没有更多了', style: TextStyle(fontSize: 12, color: _textSub))
              : _guessLoading
              ? CupertinoActivityIndicator()
              : Text('上滑加载更多', style: TextStyle(fontSize: 12, color: _textSub)),
        ),
      ),
    );
  }

  Widget _loginOut() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('提示'),
              content: Text('确定退出登录吗？', textAlign: TextAlign.center),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    // 通知后端注销 token（失败不阻塞）
                    logoutApi();
                    tokenManager.removeToken();
                    _userController.updataUserInfo(UserInfo.fromJSON({}));
                    _memberController.clear();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('确定'),
                ),
              ],
            );
          },
        );
      },
      child: Text(
        '退出登录',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 95, 95, 95),
        ),
      ),
    );
  }

  /// 用户信息（未登录态）
  Widget _buildProfileHeader() {
    return Obx(() {
      return InkWell(
        onTap: () {
          if (_userController.user.value.id.isEmpty) {
            Navigator.pushNamed(context, '/login');
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE4E1), Colors.white],
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_userController.user.value.id.isNotEmpty) {
                        _showAvatarSheet();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: _primary.withOpacity(.18),
                          backgroundImage: _avatarProvider(
                            _userController.user.value,
                          ),
                          child: _userController.user.value.id.isNotEmpty
                              ? null
                              : Icon(Icons.person, size: 36, color: _primary),
                        ),
                        // 已登录时显示头像编辑小角标
                        if (_userController.user.value.id.isNotEmpty)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: _primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_userController.user.value.id.isNotEmpty &&
                      _memberController.isMember)
                    Positioned(
                      left: -4,
                      top: -4,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/member'),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFE5A100)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'V',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_userController.user.value.id.isNotEmpty) {
                      _showNicknameDialog();
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _userController.user.value.id.isNotEmpty
                            ? (_userController.user.value.nickname.isNotEmpty
                                  ? _userController.user.value.nickname
                                  : _userController.user.value.account)
                            : '立即登录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _textMain,
                        ),
                      ),
                      if (_userController.user.value.id.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '点击修改昵称',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              _userController.user.value.id.isNotEmpty
                  ? _loginOut()
                  : Icon(Icons.chevron_right, color: Color(0xFF999999)),
            ],
          ),
        ),
      );
    });
  }

  /// 会员开通 banner
  Widget _buildVipBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Color(0xFFFFE4B5), Color(0xFFFFA07A)],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.diamond_outlined, color: _accent, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '升级美丽商城会员，尊享无限免邮',
              style: TextStyle(
                fontSize: 13,
                color: _accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/member'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '立即开通',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷入口（3 列）
  Widget _buildQuickActions() {
    final items = [
      _Entry(
        Icons.star_rounded,
        '我的收藏',
        onTap: () => Navigator.pushNamed(context, '/favorite'),
      ),
      _Entry(
        Icons.history_rounded,
        '我的足迹',
        onTap: () => Navigator.pushNamed(context, '/footprint'),
      ),
      _Entry(Icons.support_agent_rounded, '我的客服'),
    ];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(children: items.map(_buildEntryItem).toList()),
    );
  }

  /// 我的订单（5 列）
  Widget _buildOrderSection() {
    final orders = [
      _Entry(
        Icons.receipt_long_outlined,
        '全部订单',
        onTap: () => Navigator.pushNamed(context, '/orders', arguments: ''),
      ),
      _Entry(
        Icons.payment_outlined,
        '待付款',
        onTap: () => Navigator.pushNamed(context, '/orders', arguments: '待付款'),
      ),
      _Entry(
        Icons.inventory_2_outlined,
        '待发货',
        onTap: () => Navigator.pushNamed(context, '/orders', arguments: '待发货'),
      ),
      _Entry(
        Icons.local_shipping_outlined,
        '待收货',
        onTap: () => Navigator.pushNamed(context, '/orders', arguments: '待收货'),
      ),
      _Entry(
        Icons.rate_review_outlined,
        '待评价',
        onTap: () => Navigator.pushNamed(context, '/orders', arguments: '待评价'),
      ),
    ];
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的订单',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
          SizedBox(height: 16),
          Row(children: orders.map(_buildEntryItem).toList()),
        ],
      ),
    );
  }

  /// 单个图标入口
  Widget _buildEntryItem(_Entry e) {
    return Expanded(
      child: InkWell(
        onTap: e.onTap,
        child: Column(
          children: [
            Icon(e.icon, size: 28, color: _primary),
            SizedBox(height: 6),
            Text(e.label, style: TextStyle(fontSize: 12, color: _textSub)),
          ],
        ),
      ),
    );
  }
}

class _Entry {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  _Entry(this.icon, this.label, {this.onTap});
}
