import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HmHot extends StatefulWidget {
  HmHot({Key? key}) : super(key: key);

  @override
  _HmHotState createState() => _HmHotState();
}

class _HmHotState extends State<HmHot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blue,
      height: 300,
      child: Text('热门'),
    );
  }
}
