import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hm_shop/viewmodels/index.dart';

class HmSlider extends StatefulWidget {
  final List<BannerItem> bannerList;
  HmSlider({Key? key, required this.bannerList}) : super(key: key);

  @override
  _HmSliderState createState() => _HmSliderState();
}

class _HmSliderState extends State<HmSlider> {
  CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;
  Widget _getIamgeList() {
    // 获取屏幕宽度的方法
    final double screenWidth = MediaQuery.of(context).size.width;

    return CarouselSlider(
      carouselController: _controller,
      items: List.generate(widget.bannerList.length, (int index) {
        return Image.network(
          widget.bannerList[index].imageUrl,
          fit: BoxFit.cover,
          width: screenWidth,
        );
      }),
      options: CarouselOptions(
        onPageChanged: (index, reason) {
          _currentIndex = index;
          setState(() {});
        },
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
      ),
    );
  }

  Widget _getSearch() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(20),
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Text(
          '搜索...',
          style: TextStyle(color: const Color.fromARGB(200, 255, 255, 255)),
        ),
      ),
    );
  }

  Widget _getDots() {
    return Positioned(
      bottom: 2,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.bannerList.length, (int index) {
            return GestureDetector(
              onTap: () {
                _controller.animateToPage(
                  index,
                  duration: Duration(milliseconds: 500),
                );
              },
              // 动画容器组件
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 2),
                width: _currentIndex == index ? 40 : 20,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? Colors.white
                      : const Color.fromRGBO(0, 0, 0, 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [_getIamgeList(), _getSearch(), _getDots()]);
  }
}
