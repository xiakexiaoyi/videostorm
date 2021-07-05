import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../service.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/crpyt_image_cache_manager.dart';
import '../../models.dart';
import '../../res/colours.dart';
import '../../../bloc.dart';
import '../../../base.dart';
class UserFollowPage extends StatefulWidget with TTBase {
  final arguments;
  UserFollowPage({Key key, this.arguments}) : super(key: key);
  @override
  _UserFollowPageState createState() => _UserFollowPageState();
}

class _UserFollowPageState extends State<UserFollowPage> with SingleTickerProviderStateMixin,TTBase {

  RefreshController _refreshController = RefreshController(
      initialRefresh: false);
  ScrollController _scrollController = new ScrollController();
  List<User>userList;
  String errorMsg = '';
  bool loading = false;
  int offset = 0;
  User user;
  User my;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      //print(_scrollController.offset.toString()+'-'+_scrollController.position.maxScrollExtent.toString());
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 100) {
        _onLoading();
      }
    });
    if (widget.arguments == null || widget.arguments['user'] == null) {
      //获取自己的关注列表
      if (BlocObj.user.state['isLogin']) {
        my = BlocObj.user.state['user'] as User;
      } else {
        TTService.checkLogin(context);
      }
    } else {
      //获取其他人的关注列表
      user = widget.arguments['user'] as User;
    }
    if (userList == null) {
      _onRefresh();
    }
  }

  void _onRefresh() async {
    offset = 0;
    loadFollowList(true);
    print('刷新全部数据');
  }

  void loadFollowList(bool clearData) async {
    if (loading) {
      return;
    }
    loading = true;
    var res = await TTService.userFollow(
        'follow', offset, user == null ? '' : user.id);
    if (userList == null) {
      userList = new List();
    }
    if (clearData) {
      print('clearData');
      userList.clear();
    }
    if (res['code'] == 1) {
      if((res['data']['follow'] as List).length==0){
        //没有更多了
        _refreshController.loadNoData();
      }
      (res['data']['follow'] as List).forEach((element) {
        User user = User.fromJson(element);
        userList.add(user);
      });
      offset = userList.length;
    } else {
      errorMsg = '关注列表加载失败：' +
          ((res['error'] != null) ? res['error'].toString() : '未知原因');
    }

    _refreshController.refreshCompleted();
    setState(() {});
    loading = false;
  }

  // 上拉加载
  void _onLoading() async {
    print('上拉加载更多');
    loadFollowList(false);
  }

  Future<bool> onFollowButtonTapped(bool isFollow,
      User item) async {
    if (!TTService.checkLogin(context)) {
      return isFollow;
    }
    Future<Map> res;
    if (isFollow) {
      res = TTService.removeFollow(item.id);
    }
    else {
      res = TTService.addFollow(item.id);
    }
    res.then((value) {
      setState(() {
        item.following = false;
      });
      if (value['code'] == 1) {
        setState(() {
          item.ext_info.is_follow = !isFollow;
        });
        return true;
      }
      else {
        Fluttertoast.showToast(
            msg: (!isFollow ? '关注失败，' : '取消关注失败，') + value['error'] == null
                ? '未知'
                : value['error'].toString(), toastLength: Toast.LENGTH_LONG);
        return false;
      }
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, Map>(
        builder: (context, indexState) {
          return Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .backgroundColor,
              appBar: new AppBar(
                centerTitle: true,
                actions: [
                ],
                title: Text(
                  user == null ? '我关注的' : 'TA关注的', style: TextStyle(color: Theme
                    .of(context)
                    .textTheme
                    .bodyText1
                    .color),),
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                leadingWidth: dp(40),

                leading: InkWell(onTap: () {
                  Navigator.of(context).pop();
                },
                    child: Padding(padding: EdgeInsets.only(left: dp(16)),
                        child: SizedBox.expand(child: SvgPicture.asset(
                          'images/common/goback.svg', height: dp(24),
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,)))),
              ),
              body: Column(children: [
                Divider(),
                Expanded(child: _list())
              ],));
        });
  }

  _list() {
    if (errorMsg.isNotEmpty) {
      return Container(padding: EdgeInsets.all(dp(16)),child: Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMsg),
          Padding(padding: EdgeInsets.only(top: dp(8)),),
          ElevatedButton(onPressed: () {
            setState(() {
              errorMsg = '';
              userList = null;
            });
            _onRefresh();
          }, child: Text('重新加载'))
        ],)));
    }
    return
      userList == null ?
      Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(alignment: Alignment.center, child:
            Lottie.asset(
                'asset/loading.json',
                height: dp(96), width: dp(96)

            )),
          ]) : (userList.length == 0 ? Center(child: Text('未关注过任何人')) :
      Container(


          color: Theme
              .of(context)
              .backgroundColor,
          child:
          Stack(children: [
            ScrollConfiguration(
              behavior: TTBehaviorNull(),
              child: RefreshConfiguration(
                headerTriggerDistance: dp(80),
                maxOverScrollExtent: dp(100),
                footerTriggerDistance: dp(50),
                maxUnderScrollExtent: 0,
                headerBuilder: () => TTRefreshHeader(),
                footerBuilder: () => TTRefreshFooter(),
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: TTRefreshFooter(bgColor: Color(0xfff1f5f6),),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: CustomScrollView(
                    cacheExtent: 1,
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverList(
                          delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return Container(
                                  color: Theme
                                      .of(context)
                                      .backgroundColor,
                                  child: _item(userList[index]),

                                );
                              }, addAutomaticKeepAlives: false,
                              childCount: userList.length))

                    ],
                  ),
                ),
              ),
            ),
          ],)

      ));
  }

  _item(User item) {
    return
      Container(
          padding: EdgeInsets.only(
              left: dp(16), right: dp(0), top: dp(16), bottom: dp(0)),
          color: Theme
              .of(context)
              .backgroundColor,
          child:
          Column(children: [
            Row(children: [
              InkWell(onTap: () {
                Navigator.pushNamed(context, '/user', arguments: {
                  'user': item,
                  'followEvent': (isFollow, user_id) {
                    print(user_id.toString());
                    if (item.id == user_id) {
                      setState(() {
                        item.ext_info.is_follow = isFollow;
                      });
                    }
                  }
                });
              }, child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    64),
                child:
                Container(
                    height: dp(64),
                    width: dp(64),
                    color: ThemeUtils.getLightBackgroundColor(context),
                    child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 200),
                        fit: BoxFit.cover,
                        imageUrl: (TTBase.appConfig
                            .res_server +
                            'data/avatar/' +
                            TTService.generate_MD5(
                                item.id
                                    .toString()) +
                            '.dat'),
                        cacheManager: CrpytAvatarCacheManager(),
                        errorWidget: (BuildContext context,
                            Object exception,
                            StackTrace) {
                          return SvgPicture.asset(
                            'images/common/defaultavatar.svg',
                            height: dp(64),
                            width: dp(64),
                            color: Theme
                                .of(context)
                                .textTheme
                                .subtitle2
                                .color
                                .withOpacity(0.4),);
                        })),
              )),
              Padding(padding: EdgeInsets.only(left: dp(8))),
              InkWell(onTap: () {
                Navigator.pushNamed(context, '/user', arguments: {
                  'user': item,
                  'followEvent': (isFollow, user_id) {
                    print(user_id.toString());
                    if (item.id == user_id) {
                      setState(() {
                        item.ext_info.is_follow = isFollow;
                      });
                    }
                  }
                });
              }, child:
              Column(mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.username, style: TextStyle(fontSize: 16),),
                  Padding(padding: EdgeInsets.only(top: dp(4))),
                  Text(TTService.formatNum(
                      item.ext_info.fans) + '粉丝',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                  Padding(padding: EdgeInsets.only(top: dp(4))),
                  item.last_update_time < DateTime
                      .now()
                      .add(Duration(days: 365))
                      .millisecondsSinceEpoch ? Padding(
                      padding: EdgeInsets.zero) :
                  Text('最近更新' + TTService.formatTime(
                      item.last_update_time),
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],)),
              Expanded(child: Container(padding: EdgeInsets.only(right: dp(16)),
                  alignment: Alignment.centerRight,
                  child:
                  SizedBox(width: dp(56),
                      height: dp(28),
                      child:
                      item.ext_info.is_follow ?
                      OutlinedButton(

                        onPressed: () {
                          setState(() {
                            item.following = true;
                          });
                          onFollowButtonTapped(
                              item.ext_info.is_follow, item);
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                        ),
                        child:

                        item.following ? Lottie.asset(
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
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                        ),
                        onPressed: () {
                          setState(() {
                            item.following = true;
                          });
                          onFollowButtonTapped(
                              item.ext_info.is_follow, item);
                        }, child: item.following ? Lottie.asset(
                          'asset/loading.json',
                          height: dp(28), width: dp(28)) : Text('关注'),))))
            ],),
            Padding(padding: EdgeInsets.only(top: dp(16))),
            Divider(),
          ])
      );
  }
}