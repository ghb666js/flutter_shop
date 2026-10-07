import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HmCategory extends StatefulWidget {
  HmCategory({Key? key}) : super(key: key);

  @override
  _HmCategoryState createState() => _HmCategoryState();
}

class _HmCategoryState extends State<HmCategory> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            width: 100,
            color: Colors.blue,
            child: Text('分类$index'),
          );
        },
        itemCount: 20,
      ),
    );
  }
}
