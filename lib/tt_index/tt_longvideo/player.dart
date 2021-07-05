import 'dart:ui';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:like_button/like_button.dart';
import 'package:wakelock/wakelock.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../base.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../models.dart';
import '../../widget/cant_play.dart';
import '../../bloc.dart';
import '../../service.dart';
import '../../res/colours.dart';
import '../../common/crpyt_image_cache_manager.dart';

class LongVideoPlayPage extends StatefulWidget {
  final arguments;
  final followEvent;
  LongVideoPlayPage({Key key,this.arguments,this.followEvent}) : super(key: key);

  @override
  _LongVideoPlayPageState createState() => _LongVideoPlayPageState(arguments);
}

class _LongVideoPlayPageState extends State<LongVideoPlayPage> with TTBase ,SingleTickerProviderStateMixin {
  var arguments;
  VideoModel longVideoModel;
  var followEvent;
  Timer timer_videoHistory;
  Duration position = Duration.zero;
  bool following = false;
  int canPlay = 1;
  List<VideoModel>recommendVideoList = null;

  _LongVideoPlayPageState(this.arguments);

  Timer timerCloseLottlie;

  //FijkPlayer player;
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  double screenWidth;

  double playerHeight;

  @override
  Future<void> initState() {
    longVideoModel = (arguments as Map<String, Object>)['longVideoModel'];
    position = (arguments as Map<String, Object>)['position'];
    followEvent = (arguments as Map<String, Object>)['followEvent'];
    timer_videoHistory = Timer.periodic(Duration(seconds: 5), (Timer t) =>
    {

      videoHistory()
    });
    super.initState();
   checkPlay();
    loadRecommednViewList();
  }

  void videoHistory() async {
    if (this.mounted && _videoPlayerController != null &&
        _videoPlayerController.value.isInitialized &&
        _videoPlayerController.value.isPlaying) {
      Wakelock.enable();
      TTService.addHistory(longVideoModel.hash,
          _videoPlayerController.value.position.inMilliseconds /
              _videoPlayerController.value.duration.inMilliseconds);
    }
  }

  Future<bool> onFollowButtonTapped(bool isFollow,
      VideoModel videoModel) async {
    if (!TTService.checkLogin(context)) {
      following = false;
      return isFollow;
    }
    Future<Map> res;
    if (isFollow) {
      res = TTService.removeFollow(videoModel.ext_info.user_id);
    }
    else {
      res = TTService.addFollow(videoModel.ext_info.user_id);
    }
    res.then((value) {
      following = false;
      if (value['code'] == 1) {
        setState(() {
          longVideoModel.ext_info.is_follow = !isFollow;
        });
        if (followEvent != null) {
          //通知上层列表修改所有当前用户的关注状态
          followEvent(!isFollow, videoModel.ext_info.user_id);
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

  Future<void> loadRecommednViewList() async {
    recommendVideoList = null;
    TTService.getRecommendVideos(context, longVideoModel.category).then((res) {
      if (res['code'] == 1) {
        recommendVideoList = [];
        (res['data']['list'] as List).forEach((element) {
          VideoModel videoModel = VideoModel.fromJson(element);
          videoModel.image = TTBase.appConfig.res_server + element['image'];
          recommendVideoList.add(videoModel);
        });
      } else {
        recommendVideoList = [];
      }
      setState(() {

      });
    });
  }

  playVideo() async {

    if (_videoPlayerController == null) {
      //没有视频在播放
      initializePlayer();
    } else {
      // 如果有控制器，我们需要先处理旧的
      final oldVideoPlayerController = _videoPlayerController;
      final oldCheWieController = _chewieController;
      // 为下一帧的结束注册回调
      // 处理一个旧控制器
      // (调用setState后不再使用)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        print('旧播放器释放');
        await oldVideoPlayerController.dispose();
        await oldCheWieController.dispose();
      });
      // 通过将其设置为null来确保没有使用该控制器
      setState(() {
        _videoPlayerController = null;
        initializePlayer();
      });
    }
  }
checkPlay(){
  canPlay = TTService.canPlay(longVideoModel.id);
  if (canPlay != 1) {
    setState(() {

    });
  } else {
    playVideo();
  }
}
  initializePlayer() {
    _videoPlayerController = VideoPlayerController.network(
        TTBase.serverUrl + '/video/m3u8/' + longVideoModel.hash + '.m3u8')
      ..initialize().then((_) {
        _chewieController = ChewieController(
          allowedScreenSleep: false,
          allowPlaybackSpeedChanging: false,
          showControlsOnInitialize: false,
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          showOptions: false,
          startAt: position,
          looping: true,
          deviceOrientationsAfterFullScreen:[
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,]
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    print('详细页播放器释放');
    super.dispose();
    Wakelock.disable();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    if (timer_videoHistory != null) {
      timer_videoHistory.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    TTService.setAppBarLight();
    ScreenUtil.instance = ScreenUtil(width: TTBase.dessignWidth)
      ..init(context);
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    playerHeight = screenWidth * 9 / 16;

    return Scaffold(
        body: new WillPopScope (onWillPop: () async {
          closePage();
          return true;
        },
            child:
            Container(
              color: Theme
                  .of(context)
                  .backgroundColor,
              child:
              Column(
                children: [
                  Container(
                      color: Colours.dark_bg_gray,
                      height: TTBase.statusBarHeight),
                  _newPlayer(_chewieController, _videoPlayerController),
                  _userInfo(),
                  Expanded(child:
                  SingleChildScrollView(child:
                  Column(children: [
                    Container(
                      padding: EdgeInsets.only(left: dp(16),
                          right: dp(16),
                          bottom: dp(16)),
                      child: _videoInfo(),

                    ),
                    Divider(),
                    _tags(),
                    _recommendList()
                  ]
                  )

                  ))
                ],
              ),
            )));
  }

  closePage() {
    Navigator.pop(
        context, {
      'longVideoModel': longVideoModel,
      'isPlaying': (_chewieController != null && _chewieController.isPlaying)
          ? true
          : false,
      'position': _videoPlayerController != null ? _videoPlayerController.value
          .position : Duration.zero
    });
  }

  Widget _newPlayer(_chewieController, _videoPlayerController1) {
    return
      VisibilityDetector(key: Key('long_video_player_'+longVideoModel.hash), onVisibilityChanged: (visibilityInfo) {
        if(visibilityInfo.visibleFraction==0&&_videoPlayerController!=null&&_videoPlayerController.value.isPlaying){

          _videoPlayerController.pause();

        }},child:
      Stack(children: [


        Container(
            color: Colors.black,
            alignment: Alignment.center,
            height: playerHeight,
            child:
            Column(
              children: <Widget>[
                Expanded(
                  child:
                  canPlay != 1 ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                            imageUrl: longVideoModel.image + '_1.dat',
                            cacheManager: CrpytImageCacheManager()),
                        Container(color: Colors.black.withOpacity(0.6),
                            child: CantPlay(
                              canPlay: canPlay, playCallBack: () {
                              TTBase.localData.played_free = TTBase.localData
                                  .played_free + 1;
                              TTBase.localData.played_videoids.add(
                                  longVideoModel.id);
                              TTService.saveLocalData();
                              setState(() {
                                canPlay = 1;
                              });
                              playVideo();
                            },reCheck: (){
                                checkPlay();
                            },))
                      ]) : Center(
                    child:
                    _chewieController != null &&
                        _videoPlayerController.value.isInitialized
                        ? Chewie(
                      controller: _chewieController,
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(color: Colours.app_main,),
                      ],
                    ),
                  ),
                ),


              ],


            )),

        Positioned(child: InkWell(onTap: () {
          closePage();
        },
          child: Container(padding: EdgeInsets.all(dp(8)),
              child: SvgPicture.asset(
                'images/common/goback.svg', height: dp(22),
                color: Colors.white60,)),),),
      ]));
  }

  Future<bool> onFavoriteButtonTapped(bool isFavorite) async {
    if (!TTService.checkLogin(context)) {
      return isFavorite;
    }
    Future<Map> res;
    if (isFavorite) {
      res = TTService.removeFavorite(longVideoModel.hash, false, []);
      longVideoModel.ext_info.is_favorites = false;
      longVideoModel.ext_info.favorites_count =
          longVideoModel.ext_info.favorites_count - 1;
    }
    else {
      res = TTService.addFavorite(longVideoModel.hash);
      longVideoModel.ext_info.is_favorites = true;
      longVideoModel.ext_info.favorites_count =
          longVideoModel.ext_info.favorites_count + 1;
    }
    res.then((value) {
      if (value['code'] == 1) {
        if (!isFavorite) {

        }
        return !isFavorite;
      }
      else {
        Fluttertoast.showToast(
            msg: isFavorite ? '收藏失败，' : '取消收藏失败，' + value['error'] == null
                ? '未知'
                : value['error'].toString(), toastLength: Toast.LENGTH_LONG);
        return isFavorite;
      }
    });
    return !isFavorite;
  }

  Future<bool> onLikeButtonTapped(bool isLike) async {
    if (!TTService.checkLogin(context)) {
      return isLike;
    }
    Future<Map> res;
    if (isLike) {
      res = TTService.removeLike(longVideoModel.hash);
      longVideoModel.ext_info.is_like = false;
      longVideoModel.ext_info.like_count =
          longVideoModel.ext_info.like_count - 1;
    }
    else {
      res = TTService.addLike(longVideoModel.hash);
      longVideoModel.ext_info.is_like = true;
      longVideoModel.ext_info.like_count =
          longVideoModel.ext_info.like_count + 1;
    }
    res.then((value) {
      if (value['code'] == 1) {
        return !isLike;
      }
      else {
        Fluttertoast.showToast(
            msg: isLike ? '点赞失败，' : '取消点赞失败，' + value['error'] == null
                ? '未知'
                : value['error'].toString(), toastLength: Toast.LENGTH_LONG);
        return isLike;
      }
    });
    return !isLike;
  }

  _userInfo() {
    return
      Container(padding: EdgeInsets.only(
          top: dp(16), left: dp(16), right: dp(16), bottom: dp(12)), child:
      Column(children: [
        Row(children: [
          Expanded(child:
          InkWell(onTap: (){
      Navigator.pushNamed(context, '/user',arguments: {'videoModel_ExtInfo':longVideoModel.ext_info,'followEvent':followEvent});
      },child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    24),
                child:
                Container(
                    height: dp(40),
                    width: dp(40),
                    color: ThemeUtils.getLightBackgroundColor(context),
                    child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 200),
                        fit: BoxFit.cover,
                        imageUrl: (TTBase.appConfig
                            .res_server +
                            'data/avatar/' +
                            TTService.generate_MD5(
                                longVideoModel.ext_info.user_id
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
                        })),
              ),
              Padding(padding: EdgeInsets.only(left: dp(8))),
              Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(longVideoModel.ext_info.user_name),
                  Padding(padding: EdgeInsets.only(top: dp(2))),
                  Text(TTService.formatNum(
                      longVideoModel.ext_info.user_ext_info.fans) + '粉丝',
                      style: TextStyle(fontSize: 12, color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color)),
                ],)
            ],
          ))),
          SizedBox(width: dp(56),
              height: dp(28),
              child:
              longVideoModel.ext_info.is_follow ?
              OutlinedButton(

                onPressed: () {
                  setState(() {
                    following = true;
                  });
                  onFollowButtonTapped(
                      longVideoModel.ext_info.is_follow, longVideoModel);
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
                      longVideoModel.ext_info.is_follow, longVideoModel);
                }, child: following ? Lottie.asset(
                  'asset/loading.json',
                  height: dp(28), width: dp(28)) : Text('关注'),))
        ],),
      ],));
  }

  Widget _videoInfo() {
    return Column(children: [

      Row(children: [
        Expanded(child: Text(longVideoModel.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,height: 1.4),
          maxLines: 2,))
      ],),
      Padding(padding: EdgeInsets.only(top: dp(8))),
      Row(children: [
        Text(TTService.formatNum(longVideoModel.played).toString() + '次播放',
            style: TextStyle(color: Theme
                .of(context)
                .textTheme
                .subtitle2
                .color, fontSize: 12)),
        Text('.', style: TextStyle(color: Theme
            .of(context)
            .textTheme
            .subtitle2
            .color, fontSize: 12)),
        Text(TTService.formatTime((longVideoModel.add_time / 1000).round()) +
            '上传', style: TextStyle(color: Theme
            .of(context)
            .textTheme
            .subtitle2
            .color, fontSize: 12))
      ],),
      Padding(padding: EdgeInsets.only(top: dp(16))),
      Container(alignment: Alignment.center, height: dp(52), child:
      Row(mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child:
          LikeButton(
            onTap: (bool isLike) {
              return onLikeButtonTapped(isLike);
            },
            size: dp(24),
            likeBuilder: (bool isLiked) {
              return isLiked ? SvgPicture.asset(
                'images/common/thumbup_clicked.svg', height: 16,
                color: Colours.app_main,) : SvgPicture.asset(
                'images/common/thumbup.svg', height: 16, color: Theme
                  .of(context)
                  .textTheme
                  .bodyText1
                  .color,);
            },
            isLiked: BlocObj.user.state['isLogin'] &&
                longVideoModel.ext_info.is_like,
            likeCount: longVideoModel.ext_info.like_count,
            likeCountAnimationType: LikeCountAnimationType.none,
            countBuilder: (int count, bool isLiked, String text) {
              return isLiked
                  ? Text(count.toString(),
                  style: TextStyle(color: Colours.app_main, height: dp(1)))
                  : Text(count > 0 ? count.toString() : '点赞',
                style: TextStyle(fontSize: 12),);
            },
            likeCountPadding: EdgeInsets.only(top: dp(6)),
            countPostion: CountPostion.bottom,
            countDecoration: (Widget count, int likeCount) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  count,
                ],
              );
            },
          ),
          ),
          Expanded(child:
          InkWell(onTap: (){
            Fluttertoast.showToast(msg: '将减少推荐类似内容');
          },child:Padding(
              padding: EdgeInsets.only(top: dp(4)), child: Column(children: [
            SvgPicture.asset(
              'images/common/thumbdown.svg', height: dp(24), color: Theme
                .of(context)
                .textTheme
                .bodyText1
                .color,),
            Padding(padding: EdgeInsets.only(top: dp(4)),),
            Text('不喜欢', style: TextStyle(fontSize: 12),),
          ],)))),
          Expanded(child: LikeButton(
            isLiked: BlocObj.user.state['isLogin'] &&
                longVideoModel.ext_info.is_favorites,
            onTap: (bool isFavorite) {
              return onFavoriteButtonTapped(
                  isFavorite);
            },
            size: dp(24),
            likeBuilder: (bool isFavorite) {
              return isFavorite
                  ? SvgPicture.asset(
                'images/common/favorite_clicked.svg',
                height: 12, color: Colours.app_main,)
                  : SvgPicture.asset(
                'images/common/favorite.svg',
                height: 16, color: Theme
                  .of(context)
                  .textTheme
                  .bodyText1
                  .color,);
            },
            likeCount: longVideoModel.ext_info.favorites_count,
            likeCountPadding: EdgeInsets.only(top: dp(6)),
            countPostion: CountPostion.bottom,
            countDecoration: (Widget count, int likeCount) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  count,
                ],
              );
            },
            likeCountAnimationType: LikeCountAnimationType
                .none,
            countBuilder: (int count, bool isFavorite,
                String text) {
              return isFavorite ? Text(count.toString(),
                style: TextStyle(
                    color: Colours.app_main),) : Text(
                count > 0 ? count.toString() : '收藏',
                style: TextStyle(fontSize: 12),);
            },
          )),
          Expanded(child:
          InkWell(
              onTap: () {
                Share.share('【'+TTBase.appName+'推荐】' + longVideoModel.title+' https://www.baidu.com');
              },
              child:
              Padding(padding: EdgeInsets.only(top: dp(4)), child: Column(
                children: [
                  SvgPicture.asset(
                    'images/common/share.svg', height: dp(24), color: Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      .color,),
                  Padding(padding: EdgeInsets.only(top: dp(4)),),
                  Text('分享', style: TextStyle(fontSize: 12),),
                ],)))),
        ],))
    ],);
  }

  Widget _tags() {
    if (longVideoModel.tags == null) {
      return Container();
    }
    List<Widget> tagsWidget = [];
    longVideoModel.tags.forEach((value) {
      tagsWidget.add(Container(
        margin: EdgeInsets.only(right: dp(8), top: dp(8)),
        padding: EdgeInsets.only(
            left: dp(6), right: dp(6), top: dp(4), bottom: dp(4)),
        decoration: new BoxDecoration(
          color: Theme
              .of(context)
              .scaffoldBackgroundColor,
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          //设置四周边框
        ),
        child: Text(value,
          style: TextStyle(fontSize: 12),),),);
    });
    return Container(padding: EdgeInsets.only(left: dp(16), right: dp(16)),
        child: Align(alignment: Alignment.topLeft,
            child: Wrap(direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.start,
                alignment: WrapAlignment.start,
                children: tagsWidget)));
  }

  Widget _recommendList() {
    return recommendVideoList == null ? Container(
      child: Lottie.asset('asset/loading.json', height: dp(64)),) : Column(
        children:
        recommendVideoList.asMap().map((index, value) {
          return MapEntry(index,
              InkWell(
                  onTap: () {
                    longVideoModel = value;
                  checkPlay();
                    loadRecommednViewList();
//                    Navigator.pop(context);
//                    Navigator.pushNamed(context, '/longvideo_player', arguments: value);
                  },
                  child:
                  Container(
                    padding: EdgeInsets.only(left: dp(16),
                        right: dp(16),
                        top: dp(16),
                        bottom: dp(8)),
                    child:
                    Column(children: [
                      Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              16),
                          child:
                          Container(
                              height: dp(24),
                              width: dp(24),
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .subtitle2
                                  .color,
                              child: CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 200),
                                  fit: BoxFit.cover,
                                  imageUrl: (TTBase.appConfig
                                      .res_server +
                                      'data/avatar/' +
                                      TTService.generate_MD5(
                                          value.ext_info.user_id
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
                                      color: Theme
                                          .of(context)
                                          .backgroundColor,);
                                  })),
                        ),
                        Padding(padding: EdgeInsets.only(left: dp(8))),
                        Text(value.ext_info.user_name),
                      ],),
                      Padding(padding: EdgeInsets.only(top: dp(8))),
                      Row(children: [Expanded(child: Text(
                        value.title, style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,height: 1.4),
                        maxLines: 2,))
                      ]),
                      Padding(padding: EdgeInsets.only(top: dp(8))),
                      Container(height: TTBase.playerAndCoverHeight, child:
                      Stack(fit: StackFit.expand, children: [
                        ClipRRect(borderRadius: BorderRadius.circular(4), child:

                        CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                            imageUrl: value.image + '_1.dat',
                            cacheManager: CrpytImageCacheManager())),
                        Center(child: SvgPicture.asset(
                          'images/common/play.svg', height: 40, color: Colors
                            .white60,),),

                        Positioned(child: Row(children: [
                          Text(
                            TTService.formatNum(value.played).toString() +
                                '次播放', style: TextStyle(color: Colors.white),),
                          Padding(padding: EdgeInsets.only(left: dp(16)),),
                          Container(
                            padding: EdgeInsets.only(
                                left: dp(12),
                                right: dp(12),
                                top: dp(4),
                                bottom: dp(4)),
                            decoration: BoxDecoration(color: Colors.black26,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(dp(12)))),
                            child:
                            Text(
                              TTService.formateDuration(value.duration),
                              style: TextStyle(color: Colors.white),),)
                        ]), bottom: dp(8), right: dp(8))
                      ],
                      ))
                    ]),
                  )));
        }).values.toList()

    );
  }
}