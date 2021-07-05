
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../base.dart';


class BBsPage extends StatefulWidget {
  @override
  _BBsPageState createState() => _BBsPageState();
}

class _BBsPageState extends State<BBsPage> with TTBase {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(alignment:Alignment.center,child: Text('社区'));
  }
}