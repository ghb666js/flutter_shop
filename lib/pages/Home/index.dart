import 'package:flutter/cupertino.dart';
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
  final List<BannerItem> _bannerList = [
    BannerItem(
      id: '1',
      imageUrl:
          'https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meituan/1.jpg',
    ),
    BannerItem(
      id: '2',
      imageUrl:
          'https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meituan/2.png',
    ),
    BannerItem(
      id: '3',
      imageUrl:
          'https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meituan/3.jpg',
    ),
  ];
  List<Widget> _getSlivers() {
    return [
      SliverToBoxAdapter(child: HmSlider(bannerList: _bannerList)),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      // SliverList和SliverGrid只能纵向布局
      SliverToBoxAdapter(child: HmCategory()),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      SliverToBoxAdapter(child: HmSuggestion()),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(child: HmHot()),
              SizedBox(width: 10),
              Expanded(child: HmHot()),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      HmMoreList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: _getSlivers());
  }
}
