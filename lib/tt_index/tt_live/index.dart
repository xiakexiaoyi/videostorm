import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../base.dart';

class LivePage extends StatefulWidget {
  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with TTBase {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(alignment:Alignment.center,child: Text('直播'));
  }
}


