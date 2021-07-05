import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../res/colours.dart';
import '../../service.dart';
import '../../base.dart';
class RecommendFollowPage extends StatefulWidget {
  var darkMode=false;
  var followEvent;
  RecommendFollowPage({this.darkMode,this.followEvent});
  @override
  _RecommendFollowPageState createState() => _RecommendFollowPageState();
}

class _RecommendFollowPageState extends State<RecommendFollowPage> with TTBase {
  List<int>followIds=[];
  bool following=false;
  List<User> followTopUsers = [];
  @override
  void initState() {

    if (TTBase.followTopUsers.length > 6) {
      followTopUsers = TTBase.followTopUsers.sublist(0, 6);
    }
    else {
      followTopUsers = TTBase.followTopUsers;
    }
    followTopUsers.forEach((element) {followIds.add(element.id);});
    super.initState();
  }
void addFollows() async {
  if (following) {
    return;
  }
  setState(() {
    following = true;
  });

  for (int i = 0; i < followIds.length; i++) {
    await TTService.addFollow(followIds[i]);
  }
  if(widget.followEvent!=null) {
    widget.followEvent();
  }
  setState(() {
    following = false;
  });
}
  @override
  Widget build(BuildContext context) {

    return Center(child:
    Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(child: Container(alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(left: dp(32), right: dp(32),bottom: dp(16)),
              child: Text('您尚未关注过任何人，他们在' + TTBase.appName + '分享了很多优质内容哦',
                  textAlign:TextAlign.center,
                  style: TextStyle(height: 1.4,fontSize: 18,
                      color: widget.darkMode ? Colours.dark_text : Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          .color,
                      fontWeight: FontWeight.bold)))),
          Center(child:
          Wrap(children: followTopUsers.asMap().map((key, user) {
            return MapEntry(key, Container(
              padding: EdgeInsets.all(dp(16)), child: Column(children: [
InkWell(onTap: (){
  print(user.id.toString());
  if(followIds.contains(user.id)){followIds.remove(user.id);}
  else{followIds.add(user.id);}
  setState(() {

  });
},child:
                Column(children: [
                Stack(children: [


              ClipRRect(
                borderRadius: BorderRadius.circular(
                    48),
                child:


                Container(
                    height: dp(48),
                    width: dp(48),
                    color: Theme
                        .of(context)
                        .textTheme
                        .subtitle2
                        .color,
                    child:
                      CachedNetworkImage(
                          fadeInDuration: Duration(milliseconds: 200),
                          fit: BoxFit.cover,
                          imageUrl: (TTBase.appConfig
                              .res_server +
                              'data/avatar/' +
                              TTService.generate_MD5(
                                  user.id
                                      .toString()) +
                              '.dat'),
                          cacheManager: CrpytAvatarCacheManager(),
                          errorWidget: (BuildContext context,
                              Object exception,
                              StackTrace) {
                            return SvgPicture.asset(
                              'images/common/defaultavatar.svg',
                              height: dp(24),
                              width: dp(24),
                              color: Theme
                                  .of(context)
                                  .backgroundColor,);
                          }),


                    ),

              ),
                  Positioned(bottom: 0,right: 0,child:  Container(padding: EdgeInsets.all(dp(2)),child: SvgPicture.asset('images/common/checked.svg',color: Colors.white,),decoration: new BoxDecoration(
                    color:followIds.contains(user.id)? Colours.app_main:Theme.of(context).textTheme.subtitle2.color,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),height: dp(16),width: dp(16)))
                ],),
              Padding(padding: EdgeInsets.only(top: dp(4))),
              Text(user.username, style: TextStyle(
                  color: widget.darkMode ? Colours.dark_text : Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      .color, fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.only(top: dp(4))),
              Text((user.ext_info.long_video_count +
                  user.ext_info.short_video_count).toString() + '个视频 . ' +
                  TTService.formatNum(user.ext_info.fans).toString() + '粉丝', style: TextStyle(
                  fontSize: 12,
                  color: widget.darkMode ? Colours.text_gray : Theme
                      .of(context)
                      .textTheme
                      .subtitle2
                      .color)),
              Padding(padding: EdgeInsets.only(top: dp(4))),
            ],),),

              Container(height: dp(24),child:
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/user', arguments: {'user': user});
                }, child: Text('他的作品',style:TextStyle(fontSize: 12)),)),
            ],),));
          }).values.toList(),),),
          Container(child: Container(padding: EdgeInsets.only(top:dp(16)),alignment: Alignment.topCenter,child:
          ElevatedButton(
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(128, 40)),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Colours.app_main
                              .withOpacity(0.5);
                        else if (states.contains(MaterialState.disabled))
                          return Colours.app_main
                              .withOpacity(0.5);
                        return null; // Use the component's default./ Use the component's default.
                      })),
              onPressed: followIds.length==0?null:(){
                addFollows();
              }, child:following? Lottie.asset('asset/loading_white.json', height: dp(24)):Text('一键关注'+(followIds.length>0?'('+followIds.length.toString()+')':'')))),)
        ]));
  }
}