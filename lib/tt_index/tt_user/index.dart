import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../res/colours.dart';
import '../../tt_index/tt_user/videolist.dart';
import '../../widget/RoundUnderlineTabIndicator.dart';
import '../../models.dart';
import '../../service.dart';

class UserIndexPage extends StatefulWidget {
  final arguments;
  UserIndexPage({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return new UserIndexPageState();
  }
}

class UserIndexPageState extends State<UserIndexPage> with TTBase,SingleTickerProviderStateMixin {

  TabController tabController;
  ScrollController scrollController;
  TabBarView tabBarView;
  int mCurrentPosition = 0;
  bool headerExpand=false;
  var followEvent;
  bool following=false;
  GlobalKey childKey_LongVideo = GlobalKey();
  GlobalKey childKey_ShortVideo = GlobalKey();
 User user;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body:buildNestedScrollView());


  }

  @override
  void initState() {
    super.initState();
    followEvent = widget.arguments['followEvent'];
    if(widget.arguments['videoModel_ExtInfo']!=null){
      VideoModel_ExtInfo videoModel_ExtInfo=widget.arguments['videoModel_ExtInfo'];
      user=new User('','',videoModel_ExtInfo.user_id,'',videoModel_ExtInfo.user_name,0,0,0);
      user.ext_info=new User_ExtInfo(videoModel_ExtInfo.user_ext_info.long_video_count, videoModel_ExtInfo.user_ext_info.short_video_count, videoModel_ExtInfo.like_count, videoModel_ExtInfo.user_ext_info.follow,videoModel_ExtInfo.user_ext_info. fans,videoModel_ExtInfo.is_follow);

    }else if(widget.arguments['user']!=null){
      user=widget.arguments['user'];
    }
    scrollController=new ScrollController();
    scrollController.addListener(() {
     if(scrollController.offset>=270){setState(() {
       headerExpand=true;
     });}else{
       setState(() {
       headerExpand=false;
     });
     }
    });
    tabController = new TabController(vsync: this, length: 2);
    tabBarView=tabBarView;
  }
  Widget buildNestedScrollView() {
    //????????????
    return NestedScrollView(
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      controller:scrollController ,
      //???????????????????????????
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          buildSliverAppBar()];
      },
      //?????????????????????
      body:
             buidChildWidget(),
    );
  }

  buildSliverAppBar() {
    return SliverAppBar(
      title:  buildHeader(),
      leading:InkWell(onTap: () {
      Navigator.of(context).pop();
      },
      child:Container(padding: EdgeInsets.only(left: dp(16)),child: SvgPicture.asset('images/common/goback.svg',color: headerExpand?Theme.of(context).textTheme.bodyText1.color:Colors.white),)),
      leadingWidth:dp(40),
      brightness: headerExpand?ThemeUtils.isDark(context)?Brightness.dark:Brightness.light:Brightness.dark,
      //????????????
      centerTitle: true,
      //????????????true??? SliverAppBar ????????????????????????
      //????????????fase??? SliverAppBar ???????????????????????????
      pinned: true,
      //?????????true??? SliverAppBar?????????title????????????????????????
      //???????????????bottom???????????????AppBar?????????
      //?????????false??? SliverAppBar?????????title???????????????
      //???????????????bottom???????????????AppBar?????????title??????
      floating: false,
      //???snap?????????true???????????????????????????SliverAppBar????????????????????????flexibleSpace?????????????????????????????????
      //?????????snap?????????false?????????????????????????????????ListView??????????????????????????????SliverAppBar???????????????????????????
      snap: false,
      elevation: 0.0,
      //???????????????
      expandedHeight: 360,
      //AppBar??????????????????
      flexibleSpace:

      FlexibleSpaceBar(
        //??????
        //??????????????????widget??????????????????????????????????????????
        //Widget?????? ???????????????????????????????????????
        background: buildFlexibleSpaceWidget(),
      ),
      bottom: buildFlexibleTooBarWidget(),
    );
  }
  Widget buidChildWidget() {

    return TabBarView(
      controller: tabController,
      children: <Widget>[


      Container( color: Theme.of(context).backgroundColor,child: UserVideoListPage(childKey_LongVideo,scrollController,user.id,true,'defalut')),
        Container( color: Theme.of(context).backgroundColor,child: UserVideoListPage(childKey_ShortVideo,scrollController,user.id,false,'defalut')),
      ],
    );
  }

  buildHeader() {
    //????????????
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 10),
      height: 38,
     
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Expanded(child:Container(alignment: Alignment.center,child: Text(user.username,style:TextStyle(color: headerExpand?Theme.of(context).textTheme.bodyText1.color:Colors.transparent),))),
         InkWell(onTap: (){Navigator.pushNamed(context, '/search');},child: Container(width: dp(24),child: SvgPicture.asset('images/common/search.svg',color: headerExpand?Theme.of(context).textTheme.bodyText1.color:Colors.white),))
        ],
      ),
    );
  }

  Future<bool> onFollowButtonTapped(bool isFollow,
     User user) async {
    if (!TTService.checkLogin(context)) {
      following = false;
      return isFollow;
    }
    Future<Map> res;
    if (isFollow) {
      res = TTService.removeFollow(user.id);
    }
    else {
      res = TTService.addFollow(user.id);
    }
    res.then((value) {
      following = false;
      if (value['code'] == 1) {
        setState(() {
          user.ext_info.is_follow = !isFollow;
        });
        if(followEvent!=null) {
          //?????????????????????????????????????????????????????????
          followEvent(!isFollow, user.id);
        }
        return true;
      }
      else {
        Fluttertoast.showToast(
            msg: isFollow ? '???????????????' : '?????????????????????' + value['error'] == null
                ? '??????'
                : value['error'].toString(), toastLength: Toast.LENGTH_LONG);
        return false;
      }
    });
    return false;
  }
  buildFlexibleSpaceWidget() {
    return Column(
      children: [
        Container(
          height: 340,
          child:Stack(children: [
           Container(height: dp(340),child: Image.asset('images/user/banner.jpg',fit: BoxFit.cover,)),
            Container(
                child: Stack(children: [


                  Container(margin: EdgeInsets.only(top:dp(170)),padding: EdgeInsets.only(left: dp(16),right: dp(16)),
                    child: Column(children: [
                    Container(margin:EdgeInsets.only(top:dp(20),right: dp(4)),alignment: Alignment.centerRight,child:Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                      BlocObj.user.state['isLogin']&&(BlocObj.user.state['user'] as User).id==user.id?Padding(padding: EdgeInsets.only(top:dp(20),)):
                      SizedBox(width: dp(56),
                          height: dp(28),
                          child:
                          user.ext_info.is_follow ?
                          OutlinedButton(

                            onPressed: () {
                              setState(() {
                                following = true;
                              });
                              onFollowButtonTapped(
                                  user.ext_info.is_follow,user);
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                            ),
                            child:
                            following ? Lottie.asset(
                                'asset/loading.json',
                                height: dp(28), width: dp(28)) : Text(
                              "?????????", style: TextStyle(color: Theme
                                .of(context)
                                .textTheme
                                .subtitle2
                                .color),),
                          ) :
                          ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                            ),
                            onPressed: () {
                              setState(() {
                                following = true;
                              });
                              onFollowButtonTapped(
                                  user.ext_info.is_follow ,user);
                            }, child: following ? Lottie.asset(
                              'asset/loading.json',
                              height: dp(28), width: dp(28)) : Text('??????'),))
                    ],)),
                    Padding(padding: EdgeInsets.only(top:dp(16)),),
                    Row(children: [
                      Text(user.username,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                    ],),
                      Padding(padding: EdgeInsets.only(top:dp(16)),),
                      Row(
                        children: [

                            Row(
                              children: [
                                Text(user.ext_info.long_video_count.toString(), style: TextStyle(fontSize: 16, color:Theme.of(context).textTheme.bodyText1.color),),
                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('?????????',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                              ],
                            ),
Padding(padding: EdgeInsets.only(left: dp(16))),

                            Row(
                              children: [
                                Text(user.ext_info.short_video_count.toString(), style: TextStyle( fontSize: 16,color:Theme.of(context).textTheme.bodyText1.color),),
                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('?????????',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                              ],
                          ),
                          Padding(padding: EdgeInsets.only(left: dp(16))),
                          Row(
                              children: [

                                Text(TTService.formatNum(user.ext_info.like_count), style: TextStyle(fontSize: 16, color:Theme.of(context).textTheme.bodyText1.color),),

                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('??????',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                          ]
                          ),
                          Padding(padding: EdgeInsets.only(left: dp(16))),
                            InkWell(onTap: (){
                              Navigator.pushNamed(context, '/user/follow',arguments: {'user':user});
                            },child:
                            Row(
                              children: [
                                Text(TTService.formatNum(user.ext_info.follow), style: TextStyle( fontSize: 16,color:Theme.of(context).textTheme.bodyText1.color),),
                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('??????',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                          ],
                          )),
                          Padding(padding: EdgeInsets.only(left: dp(16))),
    InkWell(onTap: (){
    Navigator.pushNamed(context, '/user/fans',arguments: {'user':user});
    },child:
                            Row(
                              children: [
                                Text(TTService.formatNum(user.ext_info.fans), style: TextStyle( fontSize: 16,color:Theme.of(context).textTheme.bodyText1.color),),
                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('??????',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                              ],
                          )),
                        ],
                      ),

                  ],),decoration: new BoxDecoration(
                    color:
                   ThemeUtils.isDark(context)?Colours.dark_bg_gray:Color(0xfff9f9f9),
                      boxShadow: [BoxShadow(color: Color(0x99000000), offset: Offset(0, 0.0),    blurRadius: 16.0, spreadRadius: 0.0), BoxShadow(color: Color(0x000000), offset: Offset(10.0, 10.0)), BoxShadow(color: Color(0x000000))],
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(16),topRight:Radius.circular(16)),
                  ),),
                  Positioned(top: dp(140),left: dp(16),child:


                  Container(
                    width: dp(80),
                    height: dp(80),
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Color(0x44000000), offset: Offset(0, 0.0),    blurRadius: 6.0, spreadRadius: 0.0), BoxShadow(color: Color(0x000000), offset: Offset(10.0, 10.0)), BoxShadow(color: Color(0x000000))],
                        border: new Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        shape: BoxShape.circle,
                        color:ThemeUtils.getLightBackgroundColor(context)
                    ),
                    child: ClipRRect( borderRadius: BorderRadius.circular(
                        80),child:CachedNetworkImage(
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
                              height: dp(32),
                              width: dp(32),
                              color:Theme.of(context).textTheme.subtitle2.color.withOpacity(0.4));
                        })),
                  )),

                ],)
            )
          ],)
        ),

      ],
    );
  }


  Widget buildFlexibleTooBarWidget() {
    return PreferredSize(preferredSize: Size(MediaQuery.of(context).size.width, 44),
      child: Container(
    decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
    border:Border(bottom:BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color) )),
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child:    TabBar(
            controller: tabController,
            indicator: RoundUnderlineTabIndicator(
              wantWidth: 16,
              borderSide: const BorderSide(width: 2.0, color: Colours
                  .app_main),
            ),
            isScrollable: true,
            unselectedLabelStyle: TextStyle(
              fontSize: 16,

            ),
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelColor: Theme
                .of(context)
                .textTheme
                .bodyText1
                .color,
            labelColor: Colours.app_main,
            indicatorPadding: EdgeInsets.only(bottom: dp(8)),
            indicatorColor: Colours.app_main,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: <Widget>[
              Tab(
                text: "?????????",
              ),
              Tab(
                text: "?????????",
              ),
            ],
          ),
        ),
      ),
    );
  }



@override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }
}



