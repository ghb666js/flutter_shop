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
    _registerEvent();
    // 微任务会在build完成后执行
    Future.microtask(() {
      _key.currentState?.show();
    });
    _paidingTop = 100;
  }

  Future<void> getBannerList() async {
    _bannerList = await getBannerItem();
    // print(_bannerList);
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

  int page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  Future<void> getRecommendInfo() async {
    if (_isLoading || !_hasMore) return;
    // 展位状态，正在加载
    _isLoading = true;
    int _recommendPage = page * 10;
    _recommendList = await getRecommendData({'limit': _recommendPage});
    // 加载完成，关闭状态，放行
    _isLoading = false;
    page++;
    // 没有下一页不再加载
    if (_recommendList.length < _recommendPage) return;
  }

  Future<void> _registerEvent() async {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getRecommendInfo();
        // print('滚动到底部了');
      }
    });
  }

  Future<void> _onRefresh() async {
    int page = 1;
    bool _isLoading = false;
    bool _hasMore = true;
    await getBannerList();
    await getCategoryListData();
    await getSuggestionInfo();
    await getHotInfo();
    await getInVogueInfo();
    await getRecommendInfo();
    ToastUtils.showToast(context, '哈哈哈哈');
    _paidingTop = 0;
    setState(() {});
  }

  double _paidingTop = 0;
  GlobalKey<RefreshIndicatorState> _key = GlobalKey<RefreshIndicatorState>();
  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: EdgeInsets.only(top: _paidingTop),
      duration: Duration(milliseconds: 300),
      child: RefreshIndicator(
        key: _key,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: _getSlivers(),
          controller: _scrollController,
        ),
      ),
    );
  }
}
