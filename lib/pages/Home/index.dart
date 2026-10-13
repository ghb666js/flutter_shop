import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hm_shop/api/category.dart';
import 'package:hm_shop/api/home.dart';
import 'package:hm_shop/api/hot.dart';
import 'package:hm_shop/api/inVogue.dart';
import 'package:hm_shop/api/recommend.dart';
import 'package:hm_shop/api/suggestion.dart';
import 'package:hm_shop/components/Home/HmCategory.dart';
import 'package:hm_shop/components/Home/HmHot.dart';
import 'package:hm_shop/components/Home/HmMoreList.dart';
import 'package:hm_shop/components/Home/HmSlider.dart';
import 'package:hm_shop/components/Home/HmSuggestion.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/index.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BannerItem> _bannerList = [];
  List<CategoryItem> _categoryList = [];
  SuggestionData? _suggestionData;
  SuggestionData? _hotData;
  SuggestionData? _inVogueData;
  List<RecommendItem> _recommendList = [];

  // 推荐分页状态
  int page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  List<Widget> _getSlivers() {
    return [
      SliverToBoxAdapter(child: HmSlider(bannerList: _bannerList)),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      // SliverList和SliverGrid只能纵向布局
      SliverToBoxAdapter(child: HmCategory(categoryList: _categoryList)),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      SliverToBoxAdapter(child: HmSuggestion(data: _suggestionData)),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: HmHot(
                  data: _inVogueData,
                  backgroundColor: Color(0xFFDCE9F5),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: HmHot(
                  data: _hotData,
                  backgroundColor: Color(0xFFFBF6DC),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      HmMoreList(recommendList: _recommendList),
    ];
  }

  @override
  void initState() {
    super.initState();
    // 微任务会在build完成后执行：进入页面自动触发一次下拉刷新
    Future.microtask(() {
      _key.currentState?.show();
    });
    _paidingTop = 100;
  }

  Future<void> getBannerList() async {
    _bannerList = await getBannerItem();
  }

  Future<void> getCategoryListData() async {
    _categoryList = await getCategoryList();
  }

  Future<void> getSuggestionInfo() async {
    _suggestionData = await getSuggestionData();
  }

  Future<void> getHotInfo() async {
    _hotData = await getHotData();
  }

  Future<void> getInVogueInfo() async {
    _inVogueData = await getInVogueData();
  }

  /// 加载推荐：分页，每次 10 条，追加到列表（不替换）
  Future<void> getRecommendInfo() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final items = await getRecommendData({
        'skip': (page - 1) * 10,
        'limit': 10,
      });
      _recommendList.addAll(items);
      // 不足一页，说明没有下一页
      if (items.length < 10) _hasMore = false;
      page++;
      setState(() {});
    } catch (_) {
      // 失败保留已有数据，下次滚动/刷新重试
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 下拉刷新：重置回第 1 页后重新拉取全部
  Future<void> _onRefresh() async {
    page = 1;
    _isLoading = false;
    _hasMore = true;
    _recommendList.clear();
    await getBannerList();
    await getCategoryListData();
    await getSuggestionInfo();
    await getHotInfo();
    await getInVogueInfo();
    await getRecommendInfo();
    setState(() {});
    ToastUtils.showToast(context, '刷新成功');
    _paidingTop = 0;
  }

  double _paidingTop = 0;
  GlobalKey<RefreshIndicatorState> _key = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: EdgeInsets.only(top: _paidingTop),
      duration: Duration(milliseconds: 300),
      child: RefreshIndicator(
        key: _key,
        onRefresh: _onRefresh,
        // 用 NotificationListener 替代 ScrollController 监听：
        // 只响应首页自身滚动冒泡上来的事件，杜绝 IndexedStack 中 Mine 页滚动时误触 Home
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.maxScrollExtent > 0 &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
              getRecommendInfo();
            }
            return false;
          },
          child: CustomScrollView(slivers: _getSlivers()),
        ),
      ),
    );
  }
}
