import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hm_shop/viewmodels/index.dart';

class HmSuggestion extends StatefulWidget {
  final SuggestionData? data;
  HmSuggestion({Key? key, this.data}) : super(key: key);

  @override
  _HmSuggestionState createState() => _HmSuggestionState();
}

class _HmSuggestionState extends State<HmSuggestion> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data == null || data.subTypes.isEmpty) {
      return SizedBox(height: 300, child: Center(child: Text('暂无推荐数据')));
    }

    final subTypes = data.subTypes;
    final current = subTypes[_currentTab.clamp(0, subTypes.length - 1)];
    final goods = current.goodsItems.items;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 + Tab
          _buildHeader(data.title, subTypes),
          SizedBox(height: 10),
          // 商品网格
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: goods.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return _buildGoodsCard(context, goods[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, List<SubTypeItem> subTypes) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: subTypes.length,
              separatorBuilder: (_, __) => SizedBox(width: 16),
              itemBuilder: (context, index) {
                final selected = index == _currentTab;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTab = index;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.deepOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      subTypes[index].title,
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.white : Colors.black54,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoodsCard(BuildContext context, GoodsItem item) {
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
            desc: item.desc ?? '',
            price: item.price,
            picture: item.picture,
            orderNum: item.orderNum.toString(),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '¥${item.price}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
