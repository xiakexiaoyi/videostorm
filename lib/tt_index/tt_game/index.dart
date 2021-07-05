import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../base.dart';
class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TTBase {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }


  @override
  Widget build(BuildContext context) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: 'https://www.17sucai.com/preview/952947/2019-08-14/yx/index.html',
    );
//    return BlocBuilder<UserBloc, Map>(
//        builder: (context, indexState) {
//          return Column(
//            crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
//              children:[
//
//                Text('全局用户登陆状态：'+BlocObj.user.state['isLogin'].toString()),
//                ElevatedButton(child: Text('切换主题'), onPressed: () {
//                if (Provider.of<ThemeProvider>(context, listen: false)
//                    .getThemeMode() == ThemeMode.dark) {
//                  Provider.of<ThemeProvider>(context, listen: false).setTheme(
//                      ThemeMode.light);
//                } else {
//                  Provider.of<ThemeProvider>(context, listen: false).setTheme(
//                      ThemeMode.dark);
//                  //Navigator.pushNamed(context, '/develop');
//                }
//              },)]);
//        });
  }
}