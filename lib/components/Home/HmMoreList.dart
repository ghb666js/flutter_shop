import 'package:flutter/material.dart';
import 'package:hm_shop/viewmodels/index.dart';

class HmMoreList extends StatelessWidget {
  final List<RecommendItem> recommendList;

  HmMoreList({Key? key, this.recommendList = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendList.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(height: 300, child: Center(child: Text('暂无推荐数据'))),
      );
    }

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
        childAspectRatio: 0.72,
      ),
      itemCount: recommendList.length,
      itemBuilder: (BuildContext context, int index) =>
          _buildGoodsCard(context, recommendList[index]),
    );
  }

  Widget _buildGoodsCard(BuildContext context, RecommendItem item) {
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
        onTap: () {
          final product = ItemsData(
            id: item.id,
            name: item.name,
            desc: '',
            price: item.price,
            picture: item.picture,
            orderNum: '',
          );
          Navigator.pushNamed(context, '/product', arguments: product);
        },
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
                    style: TextStyle(fontSize: 12),
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
}
