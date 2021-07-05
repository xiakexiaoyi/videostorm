import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import '../../service.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../models.dart';
class CantPlay extends StatefulWidget {
  int canPlay=0;
  var playCallBack;
  var reCheck;
  CantPlay({this.canPlay,this.playCallBack,this.reCheck});
  @override
  _CantPlayState createState() => _CantPlayState();
}

class _CantPlayState extends State<CantPlay> with TTBase {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.canPlay == 0) {
      //需要扣今日播放次数
      return
        Center(child:
      Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: EdgeInsets.only(left: dp(16), right: dp(16)),
                child: Text('今日还可免费观看' +
                    (TTBase.appConfig.play_count_free +
                        TTBase.appConfig.play_count_free_login -
                        TTBase.localData.played_free).toString() + '个视频'+(BlocObj.user.state['isLogin']?'，您的畅看VIP已与'+formatDate(DateTime.fromMillisecondsSinceEpoch((BlocObj.user.state['user'] as User).vip_time),['yyyy','/','mm','/','dd'])+'过期，想要无限观看可分享该视频给其他人或续费':''),
                  style: TextStyle(color: Colors.white,height: 1.4),)),
            Center(child:
            Container(child: Container(padding: EdgeInsets.only(top: dp(16)),
                alignment: Alignment.topCenter,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                ElevatedButton(child: Text('播放视频'), onPressed: () {
                  if (widget.playCallBack != null) {
                    widget.playCallBack();
                  }
                },) ,BlocObj.user.state['isLogin']?Padding(padding: EdgeInsets.only(left: dp(16),right: dp(16))):Padding(padding: EdgeInsets.zero),
                      BlocObj.user.state['isLogin']?ElevatedButton(child: Text('续费VIP'), onPressed: () {

                      },):Padding(padding: EdgeInsets.zero)],))))
          ]));
    }
    else if (!BlocObj.user.state['isLogin']) {
      //无权限播放
      return Center(child:
      Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: EdgeInsets.only(left: dp(16), right: dp(16)),
                child: Text(
                  '今日已免费观看' + TTBase.appConfig.play_count_free.toString() +
                      '个视频，登录后可继续观看' +
                      TTBase.appConfig.play_count_free_login.toString() + '个视频',
                  style: TextStyle(color: Colors.white),)),
            Center(child:
            Container(child: Container(padding: EdgeInsets.only(top: dp(16)),
                alignment: Alignment.topCenter,
                child:
                ElevatedButton(child: Text('登录'), onPressed: () {
                 Navigator.pushNamed(context, '/login').whenComplete((){
                   if(widget.reCheck!=null){widget.reCheck();}
                 });

                },))))
          ]));
    } else {
      return Center(child:
      Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: EdgeInsets.only(left: dp(16), right: dp(16)),
                child: Text('今日已免费观看' + (TTBase.appConfig.play_count_free +
                    TTBase.appConfig.play_count_free_login).toString() +
                    '个视频，可明天继续免费观看，您的畅看VIP已与'+formatDate(DateTime.fromMillisecondsSinceEpoch((BlocObj.user.state['user'] as User).vip_time),['yyyy','/','mm','/','dd'])+'过期，想要无限观看可分享该视频给其他人或续费',
                  style: TextStyle(color: Colors.white,height: 1.4),)),
            Center(child:
            Container(child: Container(padding: EdgeInsets.only(top: dp(16)),
                alignment: Alignment.topCenter,
                child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                  ElevatedButton(child: Text('分享'), onPressed: () {

                  },),
                  Padding(padding: EdgeInsets.only(left: dp(16),right: dp(16))),
                  ElevatedButton(child: Text('续费VIP'), onPressed: () {

                  },)
                ],)
            )))
          ]));
    }
  }
}