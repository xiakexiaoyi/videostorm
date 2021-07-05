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
    //滑动视图
    return NestedScrollView(
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      controller:scrollController ,
      //配置可折叠的头布局
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          buildSliverAppBar()];
      },
      //页面的主体内容
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
      //标题居中
      centerTitle: true,
      //当此值为true时 SliverAppBar 会固定在页面顶部
      //当此值为fase时 SliverAppBar 会随着滑动向上滑动
      pinned: true,
      //当值为true时 SliverAppBar设置的title会随着上滑动隐藏
      //然后配置的bottom会显示在原AppBar的位置
      //当值为false时 SliverAppBar设置的title会不会隐藏
      //然后配置的bottom会显示在原AppBar设置的title下面
      floating: false,
      //当snap配置为true时，向下滑动页面，SliverAppBar（以及其中配置的flexibleSpace内容）会立即显示出来，
      //反之当snap配置为false时，向下滑动时，只有当ListView的数据滑动到顶部时，SliverAppBar才会下拉显示出来。
      snap: false,
      elevation: 0.0,
      //展开的高度
      expandedHeight: 360,
      //AppBar下的内容区域
      flexibleSpace:

      FlexibleSpaceBar(
        //背景
        //配置的是一个widget也就是说在这里可以使用任意的
        //Widget组合 在这里直接使用的是一个图片
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
    //透明组件
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
          //通知上层列表修改所有当前用户的关注状态
          followEvent(!isFollow, user.id);
        }
        return true;
      }
      else {
        Fluttertoast.showToast(
            msg: isFollow ? '关注失败，' : '取消关注失败，' + value['error'] == null
                ? '未知'
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
                              "已关注", style: TextStyle(color: Theme
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
                              height: dp(28), width: dp(28)) : Text('关注'),))
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
                                Text('长视频',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                              ],
                            ),
Padding(padding: EdgeInsets.only(left: dp(16))),

                            Row(
                              children: [
                                Text(user.ext_info.short_video_count.toString(), style: TextStyle( fontSize: 16,color:Theme.of(context).textTheme.bodyText1.color),),
                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('短视频',
                                    style: TextStyle( color:Theme.of(context).textTheme.subtitle2.color)),
                              ],
                          ),
                          Padding(padding: EdgeInsets.only(left: dp(16))),
                          Row(
                              children: [

                                Text(TTService.formatNum(user.ext_info.like_count), style: TextStyle(fontSize: 16, color:Theme.of(context).textTheme.bodyText1.color),),

                                Padding(padding: EdgeInsets.only(left: dp(4))),
                                Text('获赞',
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
                                Text('关注',
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
                                Text('粉丝',
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
                text: "长视频",
              ),
              Tab(
                text: "短视频",
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



