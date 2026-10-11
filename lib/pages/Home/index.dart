import 'package:flutter/cupertino.dart';
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
    getBannerList();
    getCategoryListData();
    getSuggestionInfo();
    getHotInfo();
    getInVogueInfo();
    getRecommendInfo();
    _registerEvent();
  }

  getBannerList() async {
    _bannerList = await getBannerItem();
    // print(_bannerList);
    setState(() {});
  }

  getCategoryListData() async {
    _categoryList = await getCategoryList();
    setState(() {});
  }

  getSuggestionInfo() async {
    _suggestionData = await getSuggestionData();
    setState(() {});
  }

  getHotInfo() async {
    _hotData = await getHotData();
    setState(() {});
  }

  getInVogueInfo() async {
    _inVogueData = await getInVogueData();
    setState(() {});
  }

  int page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  void getRecommendInfo() async {
    if (_isLoading || !_hasMore) return;
    // 展位状态，正在加载
    _isLoading = true;
    int _recommendPage = page * 10;
    _recommendList = await getRecommendData({'limit': _recommendPage});
    // 加载完成，关闭状态，放行
    _isLoading = false;
    page++;
    setState(() {});
    // 没有下一页不再加载
    if (_recommendList.length < _recommendPage) return;
  }

  void _registerEvent() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getRecommendInfo();
        // print('滚动到底部了');
      }
    });
  }

  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: _getSlivers(),
      controller: _scrollController,
    );
  }
}
