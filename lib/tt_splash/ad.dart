import 'dart:async';
import 'package:flutter/material.dart';
import '../base.dart';

class AdPage extends StatefulWidget {
  static const String routeName = '/ad';
  @override
  _AdPageState createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> with TTBase {

  Timer _timer;
  int count = 5;

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment(1.0, -1.0),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Image.asset('images/splash/ad.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 40.0, 32.0, 0.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              InkWell(onTap: () {
                navigationPage();
              }, child: Container(
                padding: EdgeInsets.fromLTRB(dp(12), dp(6),dp(12), dp(6)),
                decoration: new BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
                child: Text("$count 跳过",
                  style: TextStyle(color: Colors.white, fontSize: 14),),))
            ],),

          ),

        ],
      ),
    );
  }

  void startTime() async {
    var _duration = new Duration(seconds: 1);
    Timer(_duration, () {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (v) {
        count--;
        if (count == 0) {
          navigationPage();
        } else {
          setState(() {});
        }
      });
      return _timer;
    });
  }

  void navigationPage() {
    _timer.cancel();
    Navigator.of(context).pushReplacementNamed('/index');
  }


}
