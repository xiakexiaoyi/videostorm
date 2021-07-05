import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../service.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/events.dart';
import '../../res/colours.dart';
import '../../models.dart';
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}
ScrollController _scrollController;
Color titleColor=Colors.transparent;
Color titleTextColor=Colors.transparent;
class _MyPageState extends State<MyPage> with TTBase {
  String avatarUrl='';
  var eventBus_UpdateAvatar;
  @override
  void initState() {
    super.initState();
    TTService.refreshUserInfo(context);
    if(BlocObj.user.state['isLogin']) {

      avatarUrl = TTBase.appConfig.res_server + 'data/avatar/' +
          TTService.generate_MD5(
              (BlocObj.user.state['user'] as User).id.toString()) + '.dat';

    }
    eventBus_UpdateAvatar =
        Application.eventBus.on<UpdateAvatarEvent>().listen((event) {
          print('收到订阅事件：UpdateAvatarEvent');
          if(BlocObj.user.state['isLogin']) {
            avatarUrl = TTBase.appConfig.res_server + 'data/avatar/' +
                TTService.generate_MD5(
                    (BlocObj.user.state['user'] as User).id.toString()) +
                '.dat?' + DateTime
                .now()
                .microsecondsSinceEpoch
                .toString();
            setState(() {

            });
          }
        });
  }
@override
void dispose() {
  eventBus_UpdateAvatar?.cancel();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    TTService.refreshUserInfo(context);
    return BlocBuilder<UserBloc, Map>(
        builder: (context, indexState) {
          return Scaffold(

        body:
        Column(children: [Expanded(child:
        CustomScrollView(
          slivers: <Widget>[
          SliverPersistentHeader( pinned: true, floating: true, delegate: _SliverAppBarDelegate( minHeight: 96, maxHeight: 96,
            child: Container(
              margin: EdgeInsets.only(top:dp(16)),
              padding: EdgeInsets.only(top: TTBase.statusBarHeight),
            child: Row(
          children: <Widget>[
          Expanded(child: Row(
          children: [
          Padding(padding: EdgeInsets.only(left: TTBase().dp(16)),),
            SvgPicture.asset(
              'images/common/scan.svg', height: TTBase().dp(20), color: Theme
                .of(context)
                .textTheme
                .bodyText1
                .color,)
          ],)),
          Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap:(){
                      Navigator.pushNamed(context, '/setting');},
                      child:
                  SvgPicture.asset(
                    'images/common/setting.svg', height: TTBase().dp(20), color: Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      .color,)),

                  Padding(padding: EdgeInsets.only(right: TTBase().dp(16)),),
                ],))
        ],
        ) ,
          ), ), ),

//            SliverPersistentHeader(
//              pinned:true,
//              delegate: SliverCustomHeaderDelegate(
//              ),
//            ),
            SliverToBoxAdapter(
                child: Column(
                    children: [
                      _buildUserInfo(BlocObj.user),
                      _buildBalance(),
                      _buildInvest(),
                      _buildToolBar(),
                      _buildRecommendToolBar()
                    ]
                ))
          ],
        )
        )
        ],
        ));});

  }



  Widget _buildUserInfo(UserBloc userBloc) {
    return Container(
      padding: EdgeInsets.only(
          top: dp(8),
          bottom: dp(0),
          left: dp(16),
          right: dp(16)),
      child: Column(
        children: [
          userBloc.state['isLogin'] ?
          Column(children: [
            Row(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child:
                  Container(
                      height: dp(80),
                      width: dp(80),
                      color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color,
                      child: CachedNetworkImage(fit: BoxFit.cover,
                          fadeInDuration: Duration.zero,
                          imageUrl: avatarUrl.isNotEmpty ? avatarUrl : TTBase
                              .appConfig.res_server + 'data/avatar/' +
                              TTService.generate_MD5(
                                  (BlocObj.user.state['user'] as User).id
                                      .toString()) + '.dat',
                          cacheManager: CrpytAvatarCacheManager(),
                          errorWidget: (BuildContext context, Object exception,
                              StackTrace) {
                            return SvgPicture.asset(
                              'images/common/defaultavatar.svg', height: dp(48),
                              width: dp(48),
                              color: Theme
                                  .of(context)
                                  .backgroundColor,);
                          })),
                ),
                Padding(padding: EdgeInsets.only(left: dp(8)),),
                Container(alignment: Alignment.centerLeft,
                  child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((userBloc.state['user'] as User).username,
                        style: TextStyle(
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),),
                      Padding(padding: EdgeInsets.only(top: dp(4)),),
                      Container(alignment: Alignment.centerLeft,
                          child: Text('VIP有效期：' + formatDate(
                              DateTime.fromMillisecondsSinceEpoch(
                                  (userBloc.state['user'] as User).vip_time),
                              [yyyy, '-', mm, '-', d])
                            , style: TextStyle(fontSize: 12, color: DateTime
                                .fromMillisecondsSinceEpoch(
                                (userBloc.state['user'] as User).vip_time)
                                .difference(DateTime.now())
                                .inDays <= 0 ? Colours.app_main : Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color),)),
                      Padding(padding: EdgeInsets.only(top: dp(4)),),
//              Container(height: dp(24),child: ElevatedButton(onPressed: (){}, child: Text('续费')))

                      Row(children: [
                        Text('点击续费享8折优惠'),
                        Padding(padding: EdgeInsets.only(left: dp(2))),
                        SvgPicture.asset('images/my/gift.svg', height: dp(12),)
                      ],),
                    ],),),

                Expanded(child: Container()),
                InkWell(onTap: () {
                  Navigator.pushNamed(context, '/user',
                      arguments: {'user': userBloc.state['user'] as User});
                },
                    child: Row(
                        children: [
                          Text('个人主页 ', style: TextStyle(color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2
                              .color),),
                          SvgPicture.asset(
                            'images/common/goto.svg', height: dp(12),
                            color: Theme
                                .of(context)
                                .textTheme
                                .subtitle2
                                .color,)
                        ]))
                ,
              ],),

            Padding(padding: EdgeInsets.only(bottom: dp(16))),
            Row(
              children: [
                Expanded(child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text((userBloc.state['user'] as User).ext_info
                          .long_video_count.toString(), style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color, fontWeight: FontWeight.bold),),

                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: dp(4))),
                  Text('长视频',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],

                ), flex: 1,),
                Expanded(child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text((userBloc.state['user'] as User).ext_info
                          .short_video_count.toString(), style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color, fontWeight: FontWeight.bold),),

                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: dp(4))),
                  Text('短视频',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],

                ),),
                Expanded(child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(TTService.formatNum(
                          (userBloc.state['user'] as User).ext_info.like_count),
                        style: TextStyle(color: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .color, fontWeight: FontWeight.bold),),


                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: dp(4))),
                  Text('获赞',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],

                ), flex: 1,),
                Expanded(child:InkWell(onTap: (){
                  Navigator.pushNamed(context, '/user/follow').whenComplete(() =>  TTService.refreshUserInfo(context));
                },child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(TTService.formatNum(
                          (userBloc.state['user'] as User).ext_info.follow),
                        style: TextStyle(color: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .color, fontWeight: FontWeight.bold),),


                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: dp(4))),
                  Text('关注',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],

                )),),
                Expanded(child:InkWell(onTap: (){
    Navigator.pushNamed(context, '/user/fans').whenComplete(() =>  TTService.refreshUserInfo(context));
    },child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(TTService.formatNum(
                          (userBloc.state['user'] as User).ext_info.fans),
                        style: TextStyle(color: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .color, fontWeight: FontWeight.bold),),


                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: dp(4))),
                  Text('粉丝',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],

                ),)),
              ],
            ),
          ],) :
          Container(

              padding: EdgeInsets.only(bottom: dp(16)),
              alignment: Alignment.center,
              child:
              Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  Text('欢迎来到' + TTBase.appName, style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),),
                  Padding(padding: EdgeInsets.only(top: dp(8)),),
                  Text('登录后更懂你，内容更有趣'),
                  Padding(padding: EdgeInsets.only(top: dp(8)),),
                  ElevatedButton(onPressed: () {
                    Navigator.pushNamed(context, '/login', arguments: {
                      'refere': 'my'
                    });
                  }, child: Text('登录/注册'),)
                ],)),

        ],
      ),
    );
  }
Widget _buildBalance(){
  return
    Container(
        padding: EdgeInsets.only(left:dp(16),right: dp(16),top: dp(24)),
  child: Column(
  children: [  Container(child: Row(children: [

    Expanded(
        child: InkWell(
          onTap: () {
            Fluttertoast.showToast(
                msg: '余额', toastLength: Toast.LENGTH_SHORT);
          },
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:ThemeUtils.isDark(context)?
                  [
                    Color(0xff5e5140),
                    Color(0xffa48c74),
                  ]: [
                    Color(0xfff4efe9),
                    Color(0xffddcab9),
                  ],
                ),
              ),
              child:
              Container(
                padding: EdgeInsets.all(dp(16)), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('钱包余额', style: TextStyle(
                          color: ThemeUtils.isDark(context)?Colors.white:Colours.text,
                          fontWeight: FontWeight.bold),),
                      Padding(padding: EdgeInsets.only(top: dp(4))),
                      Text('（元）', style: TextStyle(
                          color: ThemeUtils.isDark(context)?Colors.white:Colours.text, fontSize: 12)),
                    ],
                  ),

                  Padding(padding: EdgeInsets.only(top: dp(8))),
                  Text('0.00', style: TextStyle(
                      color:ThemeUtils.isDark(context)?Colors.white:Colours.text,
                      fontWeight: FontWeight.bold),)
                ],
              ),
              )),)),
    Padding(padding: EdgeInsets.only(left: 8, right: 8)),
    Expanded(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:ThemeUtils.isDark(context)?
              [
                Color(0xff5e5140),
                Color(0xffa48c74),
              ]: [
                Color(0xfff4efe9),
                Color(0xffddcab9),
              ],
            ),
          ),
          child:
          Container(padding: EdgeInsets.all(dp(16)), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('分享送VIP', style: TextStyle(
                  color: ThemeUtils.isDark(context)?Colors.white:Colours.text, fontWeight: FontWeight.bold),),
              Padding(padding: EdgeInsets.only(top: dp(8))),
              Text('推广1人送2天VIP', style: TextStyle(
                  color: ThemeUtils.isDark(context)?Colors.white:Colours.text, fontSize: 12),)
            ],
          ),
          )),),

  ],),),]));
}
  Widget _buildInvest() {
    return
      Container(
          padding: EdgeInsets.only(left:dp(16),right: dp(16),top: dp(16),bottom: dp(16)),
        child:
      Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color: Theme.of(context).backgroundColor

      ),

      child: Column(
        children: [

        Container(child:
        Row(
            children: [
              Expanded(child: InkWell(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: '购买会员', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top:dp(16),bottom: dp(16),left: dp(8),right: dp(8)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        color: Theme.of(context).backgroundColor

                    ),
                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/vip.svg',width: dp(24),color: Colours.app_main,),
                        Padding(padding: EdgeInsets.only(top: dp(6))),
                        Text('购买会员', style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color))
                      ],
                    ),
                  ))),
              Padding(padding: EdgeInsets.only(left: 4, right: 4)),
              Expanded(child: InkWell(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: '钱包充值', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top:dp(16),bottom: dp(16),left: dp(8),right: dp(8)),

                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/rchg.svg',width: dp(24),color: Colours.app_main,),
                        Padding(padding: EdgeInsets.only(top: dp(6))),
                        Text('钱包充值', style: TextStyle(
                            color:Theme.of(context).textTheme.bodyText1.color))
                      ],
                    ),
                  ))),
              Padding(padding: EdgeInsets.only(left: 4, right: 4)),
              Expanded(child: InkWell(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: '提现', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top:dp(16),bottom: dp(16),left: dp(8),right: dp(8)),

                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/withdraw.svg',width: dp(24),color: Colours.app_main,),
                        Padding(padding: EdgeInsets.only(top: dp(6))),
                        Text('提现', style: TextStyle(
                            color:Theme.of(context).textTheme.bodyText1.color))
                      ],
                    ),
                  ))),
              Padding(padding: EdgeInsets.only(left: 4, right: 4)),
              Expanded(child: InkWell(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: '购买会员', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top:dp(16),bottom: dp(16),left: dp(8),right: dp(8)),

                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/moneyconvert.svg',width: dp(24),color: Colours.app_main,),
                        Padding(padding: EdgeInsets.only(top: dp(6))),
                        Text('游戏转换', style: TextStyle(
                            color:Theme.of(context).textTheme.bodyText1.color))
                      ],
                    ),
                  ))),

            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildToolBar() {
    return
      Container(
          padding: EdgeInsets.only(top: dp(0), left: dp(16), right: dp(16)),
          child:
          Container(
              padding: EdgeInsets.only(bottom: dp(8)),
              decoration: new BoxDecoration(
                color: Theme
                    .of(context)
                    .backgroundColor,
                //设置四周圆角 角度 这里的角度应该为 父Container height 的一半
                borderRadius: BorderRadius.all(Radius.circular(8),),
              ),
              child: Container(child: Column(children: [
                Container(
                    padding: EdgeInsets.all(dp(16)),

                    alignment: Alignment.centerLeft,
                    child: Text('常用功能', textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),)),
                Divider(color: Theme
                    .of(context)
                    .scaffoldBackgroundColor,),
                Row(children: [


               Expanded(

                          child:InkWell(
                              onTap: () {
                                if(TTService.checkLogin(context)) {
                                  Navigator.pushNamed(context, '/playrecord');
                                }
                              },
                               child: Container(
                        padding: EdgeInsets.all(dp(8)),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'images/my/playrecord.svg', width: dp(24),
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1
                                  .color,),
                            Padding(padding: EdgeInsets.only(top: dp(4))),
                            Text('播放记录', style: TextStyle(
                                fontSize: 12,
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1
                                    .color))
                          ],
                        ),
                      ))),
                  Padding(padding: EdgeInsets.only(left: 4, right: 4)),
                  Expanded(child:
                  InkWell(
                      onTap: () {
    if(TTService.checkLogin(context)) {
      Navigator.pushNamed(context, '/favorite');
    }
                      },
                      child:
                  Container(
                    padding: EdgeInsets.all(dp(8)),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'images/common/favorite.svg', width: dp(24),
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,),
                        Padding(padding: EdgeInsets.only(top: dp(4))),
                        Text('我的收藏', style: TextStyle(
                            fontSize: 12,
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color))
                      ],
                    ),
                  ))),
                  Padding(padding: EdgeInsets.only(left: 4, right: 4)),
                  Expanded(child: Container(
                    padding: EdgeInsets.all(dp(8)),
                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/buy.svg', width: dp(26),
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,),
                        Padding(padding: EdgeInsets.only(top: dp(4))),
                        Text('我的购买', style: TextStyle(
                            fontSize: 12,
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color))
                      ],
                    ),
                  )),
                ],),
                Row(children: [
                  Expanded(child: InkWell(
                      onTap: () {
                        Fluttertoast.showToast(
                            msg: '我的作品', toastLength: Toast.LENGTH_SHORT);
                      },
                      child: Container(
                        padding: EdgeInsets.all(dp(8)),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'images/my/videos.svg', width: dp(24),
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1
                                  .color,),
                            Padding(padding: EdgeInsets.only(top: dp(4))),
                            Text('我的作品', style: TextStyle(
                                fontSize: 12,
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1
                                    .color))
                          ],
                        ),
                      ))),
                  Padding(padding: EdgeInsets.only(left: 4, right: 4)),
                  Expanded(child: Container(
                    padding: EdgeInsets.all(dp(8)),
                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/level.svg', width: dp(24),
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,),
                        Padding(padding: EdgeInsets.only(top: dp(4))),
                        Text('等级中心', style: TextStyle(
                            fontSize: 12,
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color))
                      ],
                    ),
                  )),
                  Padding(padding: EdgeInsets.only(left: 4, right: 4)),
                  Expanded(child: Container(
                    padding: EdgeInsets.all(dp(8)),
                    child: Column(
                      children: [
                        SvgPicture.asset('images/my/videocamera.svg', width: dp(
                            24), color: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .color,),
                        Padding(padding: EdgeInsets.only(top: dp(4))),
                        Text('创作中心', style: TextStyle(
                            fontSize: 12,
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color))
                      ],
                    ),
                  )),

                ],)
              ],),
              )));
  }

  Widget _buildRecommendToolBar() {
    return
      Container(
          padding: EdgeInsets.only(top:dp(16),left: dp(16),right: dp(16),bottom: dp(16)),
          child:
      Container(
        padding: EdgeInsets.only(bottom: dp(8)),
        decoration: new BoxDecoration(
          color: Theme
              .of(context)
              .backgroundColor,
          //设置四周圆角 角度 这里的角度应该为 父Container height 的一半
          borderRadius: BorderRadius.all(Radius.circular(8),),
        ),
        child: Container(child: Column(children: [
          Container(
              padding: EdgeInsets.all(dp(16)),
              alignment: Alignment.centerLeft,
              child: Text('推荐功能', textAlign: TextAlign.left,style: TextStyle(fontSize: 14))),
          Divider(color: Theme.of(context).scaffoldBackgroundColor,),
          Row(children: [
            Expanded(
                child: Container(
                  padding: EdgeInsets.all(dp(8)),
                  child: Column(
                    children: [
                      SvgPicture.asset('images/my/game.svg',width: dp(26),color: Theme.of(context).textTheme.bodyText1.color,),
                      Padding(padding: EdgeInsets.only(top: dp(4))),
                      Text('玩游戏', style: TextStyle(
                          fontSize: 12,
                          color:Theme.of(context).textTheme.bodyText1.color))
                    ],
                  ),
                )),
            Expanded(child: Container(
              padding: EdgeInsets.all(dp(8)),
              child: Column(
                children: [
                  SvgPicture.asset('images/my/live.svg',width: dp(24),color: Theme.of(context).textTheme.bodyText1.color,),
                  Padding(padding: EdgeInsets.only(top: dp(4))),
                  Text('开直播', style: TextStyle(
                      fontSize: 12,
                      color:Theme.of(context).textTheme.bodyText1.color))
                ],
              ),
            )),
            Expanded(child: Container(
              padding: EdgeInsets.all(dp(8)),
              child: Column(
                children: [
                  SvgPicture.asset('images/my/agent.svg',width: dp(24),color: Theme.of(context).textTheme.bodyText1.color,),
                  Padding(padding: EdgeInsets.only(top: dp(4))),
                  Text('推广专区', style: TextStyle(
                      fontSize: 12,
                      color:Theme.of(context).textTheme.bodyText1.color))
                ],
              ),
            )),
            Expanded(child: Container(
              padding: EdgeInsets.all(dp(8)),
              child: Column(
                children: [
                  SvgPicture.asset('images/my/rec_id.svg',width: dp(24),color: Theme.of(context).textTheme.bodyText1.color,),
                  Padding(padding: EdgeInsets.only(top: dp(4))),
                  Text('身份卡', style: TextStyle(
                      fontSize: 12,
                      color:Theme.of(context).textTheme.bodyText1.color))
                ],
              ),
            )),
          ],),
        ],),
        )));
  }



}
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight, @required this.maxHeight, @required this.child,});

  final double minHeight;
  final double maxHeight;
  final Widget child;

  void updateStatusBarBrightness(shrinkOffset, context) {
    Brightness brightness = Theme
        .of(context)
        .brightness;
    print(brightness.toString());

    if (brightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override double get minExtent => minHeight;

  @override double get maxExtent => max(maxHeight, minHeight);

  @override Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    updateStatusBarBrightness(shrinkOffset, context);
    return new SizedBox.expand(child: Container(
        color: shrinkOffset > 0 ? Theme
            .of(context)
            .backgroundColor : Theme
            .of(context)
            .scaffoldBackgroundColor,
        child: child));
  }

  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}

