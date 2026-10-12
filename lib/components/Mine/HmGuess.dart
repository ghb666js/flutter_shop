import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HmGuess extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 60,
      color: Color(0xFFF6F6F6), // 不透明背景，避免下方商品滚动时透出
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildLine()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: Color(0xFFFA6D6D), size: 18),
                SizedBox(width: 6),
                Text(
                  '猜你喜欢',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '为你推荐',
                  style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          Expanded(child: _buildLine()),
        ],
      ),
    );
  }

  /// 左右渐变装饰线
  Widget _buildLine() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, Color(0xFFCCCCCC), Colors.transparent],
        ),
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 60;

  @override
  // TODO: implement minExtent
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
