import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HmMoreList extends StatefulWidget {
  HmMoreList({Key? key}) : super(key: key);

  @override
  _HmMoreListState createState() => _HmMoreListState();
}

class _HmMoreListState extends State<HmMoreList> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 300,
          alignment: Alignment.center,
          color: Colors.blue,
          child: Text('第${index + 1}个商品'),
        );
      },
    );
  }
}
