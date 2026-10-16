import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hm_shop/viewmodels/index.dart';

class HmHot extends StatelessWidget {
  final SuggestionData? data;
  final Color backgroundColor;

  HmHot({Key? key, this.data, this.backgroundColor = const Color(0xFFDCE9F5)})
    : super(key: key);

  static const Color _titleColor = Color(0xFF8E2F22);
  static const Color _priceColor = Color(0xFFC0504D);

  @override
  Widget build(BuildContext context) {
    final subTypes = data?.subTypes ?? <SubTypeItem>[];
    final items = subTypes.isNotEmpty
        ? subTypes.first.goodsItems.items.take(2).toList()
        : <GoodsItem>[];
    final subTitle = subTypes.isNotEmpty ? subTypes.first.title : '';

    return Container(
      height: 230,
      padding: EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  data?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _titleColor,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: _priceColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: items.length > index
                        ? _buildGoods(context, items[index])
                        : SizedBox.shrink(),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoods(BuildContext context, GoodsItem item) {
    return InkWell(
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
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.picture,
                width: double.infinity,
                fit: BoxFit.cover,
                // 图片加载失败时，404图片
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white,
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '¥${item.price}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _priceColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
