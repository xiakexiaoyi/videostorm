import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../service.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../models.dart';
import '../../res/colours.dart';
import '../../tt_index/tt_longvideo/listplayer.dart';
import '../../widget/recommend_follow.dart';
class VideoListPage extends StatefulWidget {
  VideoListPage({this.longVideoCategory,this.tabPageIndex});
  LongVideoCategory longVideoCategory;
  int tabPageIndex;
  int offset=0;


  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage>
    with AutomaticKeepAliveClientMixin,TTBase {
  RefreshController _refreshController = RefreshController(
      initialRefresh: false);
  ScrollController _scrollController = new ScrollController();
  bool loading = false;
  bool reloading = false;
  String errorMsg = '';
  int timestamps = 0;
  List<VideoModel> videoList = null;
  List<User>followList;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      //print(_scrollController.offset.toString()+'-'+_scrollController.position.maxScrollExtent.toString());
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - TTBase.screenHgight) {
        _onLoading();
      }
    });
    if (videoList == null) {
      _onRefresh();
    }
  }

  void _onRefresh() async {
    errorMsg = '';
    loadVideoList(true);
    if (widget.longVideoCategory.id == 0) {
      loadFollowList();
    }
    setState(() {
      reloading = true;
    });
    widget.offset = 0;
    TTBase.longVideoAutoPlay = false;
    print('刷新全部数据');
  }

  Future<void> loadFollowList() async {
    print('加载关注列表');
    if (followList != null) {
      followList.clear();
    }
    followList = [];
    var res = await TTService.userFollow('update', 0,'');
    if (res['code'] == 1) {
      (res['data']['follow'] as List).forEach((element) {
        User user = User.fromJson(element);
        followList.add(user);
      });
    }
    followList.add(new User(
        '',
        '',
        0,
        '',
        '全部关注',
        0,
        0,0));
    setState(() {

    });
  }

  void loadVideoList(bool clearData) async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    var res;
    if (widget.longVideoCategory.id == 0) {
      res = await TTService.getFollowVideos(true, widget.offset);
    }
    else {
      res = await TTService.getVideoList(
          context, widget.longVideoCategory.id);
    }
    if (videoList == null) {
      videoList = new List();
    }
    if (clearData) {
      print('clearData');
      videoList.clear();
    }
    if (res['code'] == 1) {
      (res['data']['list'] as List).forEach((element) {
        VideoModel videoModel = VideoModel.fromJson(element);
        videoModel.image = TTBase.appConfig.res_server + element['image'];
        videoList.add(videoModel);
      });
      widget.offset = videoList.length + 1;
    } else {
      errorMsg = '视频加载失败：' +
          ((res['error'] != null) ? res['error'].toString() : '未知原因');
    }


    loading = false;
    reloading = false;

    _refreshController.refreshCompleted();
    setState(() {});
  }

  // 上拉加载
  void _onLoading() async {
    print('上拉加载更多');
    loadVideoList(false);
  }

  @override
  Widget build(BuildContext context) {
    print('列表重绘' + MediaQuery
        .of(context)
        .orientation
        .toString());
    if (MediaQuery
        .of(context)
        .orientation == Orientation.landscape) {


    }
    if (widget.longVideoCategory.id == 0 && !BlocObj.user.state['isLogin']) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('登录后更懂你，内容更有趣'),
          Padding(padding: EdgeInsets.only(top: dp(8)),),
          ElevatedButton(onPressed: () {
            Navigator.pushNamed(context, '/login').then((value) {
              _onRefresh();
            });
          }, child: Text('登录'))
        ],);
    }
    else if (errorMsg.isNotEmpty) {
      return Container(padding: EdgeInsets.all(16),child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMsg),
          Padding(padding: EdgeInsets.only(top: dp(8)),),
          ElevatedButton(onPressed: () {
            setState(() {
              errorMsg = '';
              videoList = null;
            });
            _onRefresh();
          }, child: Text('重新加载'))
        ],));
    } else if (widget.longVideoCategory.id == 0 && followList != null &&
        followList.length == 1) {
      //尚未关注任何人
      return RecommendFollowPage(darkMode: false, followEvent: () {
        setState(() {
          followList = null;
          videoList = null;
        });
        _onRefresh();
      },);
    }
    return
      videoList == null ?
      Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
                'asset/loading.json',
                height: dp(128), width: dp(128)

            ),
          ]) :
      (videoList.length == 0 ? Center(child: Text(
          widget.longVideoCategory == 0 ? '暂无内容，去关注更多人吧' : '暂无内容，去别的地方看看吧')) :
      Container(
        color: Theme
            .of(context)
            .scaffoldBackgroundColor,
        child: ScrollConfiguration(
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
                  widget.longVideoCategory.id == 0 && followList != null &&
                      followList.length > 0 ?
                  SliverToBoxAdapter(child: Container(color: Theme
                      .of(context)
                      .backgroundColor,
                    margin: EdgeInsets.only(bottom: dp(8)),
                    height: dp(80),
                    child: ListView(scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: followList.asMap().map((key, user) {
                        return new MapEntry(key, InkWell(onTap: () {
                          if (user.id > 0) {
                            Navigator.pushNamed(
                                context, '/user', arguments: {'user': user});
                          } else {
                            print('进入关注列表');
                            Navigator.pushNamed(context, '/user/follow');
                          }
                        },
                            child: Container(padding: EdgeInsets.only(
                                top: dp(8),
                                bottom: dp(6),
                                right: dp(0),
                                left: dp(16)),
                              child: Column(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      48),
                                  child:
                                  Container(
                                    height: dp(48),
                                    width: dp(48),
                                    color: ThemeUtils.getLightBackgroundColor(
                                        context),
                                    child:
                                    user.id == 0 ?
                                    Container(padding: EdgeInsets.all(dp(12)),
                                      child: SvgPicture.asset(
                                          'images/common/userlist.svg',
                                          height: dp(24),
                                          width: dp(24),
                                          color: Theme
                                              .of(context)
                                              .textTheme
                                              .subtitle2
                                              .color),)
                                        : CachedNetworkImage(
                                        fadeInDuration: Duration(
                                            milliseconds: 200),
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
                                            height: dp(48),
                                            width: dp(48),
                                            color: Theme
                                                .of(context)
                                                .textTheme
                                                .subtitle2
                                                .color
                                                .withOpacity(0.4),);
                                        }),


                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(top: dp(4))),
                                Container(alignment: Alignment.center,
                                    width: dp(56),
                                    child: Text(user.username, softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 12),))
                              ],),
                            )));
                      }).values.toList(),),)) :
                  SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.zero,),),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            return reloading ? Container() : Container(
                                margin: EdgeInsets.only(bottom: dp(8)),
                                color: Theme
                                    .of(context)
                                    .backgroundColor,
                                child: ListPlayer(
                                  longVideoModel: videoList[index],
                                  scrollController:
                                  _scrollController,
                                  followEvent: (isFollow, user_id) {
                                    videoList.where((element) =>
                                    element.ext_info.user_id == user_id)
                                        .forEach((element) {
                                      element.ext_info.is_follow = isFollow;
                                    });
                                    setState(() {

                                    });
                                  },));
                          }, addAutomaticKeepAlives: false,
                          childCount: videoList.length))
                  // },addAutomaticKeepAlives: false,childCount: videoList.length))
                  // MediaQuery.of(context).orientation==Orientation.landscape?true:false

                ],
              ),
            ),
          ),
        ),
      ));
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
