import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lottie/lottie.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:wakelock/wakelock.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/crpyt_image_cache_manager.dart';
import '../../common/events.dart';
import '../../res/colours.dart';
import '../../widget/cant_play.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../../models.dart';
import '../../service.dart';

class ListPlayer extends StatefulWidget {
  VideoModel longVideoModel;
  ScrollController scrollController;
  final followEvent;
  ListPlayer({Key key, @required this.longVideoModel,this.scrollController,this.followEvent}) : super(key: key);
  //_PostVideos createState() => _PostVideos(this.videoModel,this.scrollController);
  @override
  _ListPlayerState createState() {
    return _ListPlayerState(this.longVideoModel,this.scrollController);
  }
}

class _ListPlayerState extends State<ListPlayer> with TTBase {
  VideoModel longVideoModel;
  ScrollController scrollController;

  _ListPlayerState(this.longVideoModel, this.scrollController);

  bool showVideo;
  bool _showCover = true;
  bool _visible = true;
  bool autoplaying = false;
  bool showTitle = true;
  bool following = false;
  int canPlay = 1;
  var eventBus_StopPlay;
  var scrollListener;
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  Timer timer;
  Timer timer_videoHistory;

  void startTimer() {
    final Duration duration = Duration(milliseconds: 500);
    cancelTimer();

    timer = Timer.periodic(duration, (timer) {
      if (this.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!this.mounted) {
            return;
          }
          RenderBox renderBox = context.findRenderObject();
          var offset = renderBox.localToGlobal(Offset.zero);
          var height = renderBox.size.height;
          if ((offset.dy < 80 || offset.dy > TTBase.screenHgight - height) &&
              canPlay != 1) {
            setState(() {
              canPlay = 1;
            });
          }
          if (_videoPlayerController == null) {
            return;
          }
          if (!autoplaying && offset.dy < TTBase.screenHgight / 2.0 &&
              offset.dy > (TTBase.screenHgight / 2.0 - height / 2.0)) {
            autoplaying = true;
            Future.delayed(Duration(milliseconds: 1000), () {
              if (offset.dy < TTBase.screenHgight / 2.0 &&
                  offset.dy > (TTBase.screenHgight / 2.0 - height / 2.0)) {
                print('播放器' + longVideoModel.title + '进入正视图');
                if (_videoPlayerController != null &&
                    _videoPlayerController.value.isPlaying) {
                  print('播放器正在播放中');
                  return;
                }
                readyPlay(false);
              } else {
                print('播放器' + longVideoModel.title + '未能停止在正视图中，不自动播放');
                autoplaying = false;
              }
            });
          } else
          if (offset.dy < 80 || offset.dy > TTBase.screenHgight - height) {
            autoplaying = false;
            if (_videoPlayerController == null ||
                !_videoPlayerController.value.isPlaying) {
              return;
            }
            else {
              print('播放器' + longVideoModel.title + '不在正视图');
              _chewieController.pause();
              super.setState(() {
                _showCover = true;
              });
            }
          }
        });
      }
    });
  }

  void cancelTimer() {
    if (timer != null) {
      timer.cancel();
    }
  }


  @override
  void initState() {
    startTimer();
    timer_videoHistory = Timer.periodic(Duration(seconds: 5), (Timer t) =>
    {

      videoHistory()
    });
    showVideo = false;
    super.initState();
    eventBus_StopPlay =
        Application.eventBus.on<StopPlayLongVideoEvent>().listen((event) {
          print('收到事件订阅：StopPlayLongVideoEvent' + widget.longVideoModel.title);
          if (_videoPlayerController != null &&
              _videoPlayerController.value.isPlaying) {
            playOrPause();
          }
        });
  }

  @override
  void dispose() {
    cancelTimer();
    if (timer_videoHistory != null) {
      timer_videoHistory.cancel();
    }
    print('播放器释放：' + longVideoModel.title);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    scrollController.removeListener(scrollListener);
    eventBus_StopPlay?.cancel();
    super.dispose();
  }

  void scrollToCenter(int duration) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = context.findRenderObject();
      var offset = renderBox.localToGlobal(Offset.zero);
      var height = renderBox.size.height;
      double animateTo = offset.dy + widget.scrollController.offset - height;
      print(widget.scrollController.offset);
      if (offset.dy < height && widget.scrollController.offset < height) {
        animateTo = 0;
      }

      widget.scrollController.animateTo(
          animateTo,
          duration: Duration(milliseconds: duration),
          curve: Curves.ease).then((value) {
        readyPlay(false);
      });
    });
  }

  void playOrPause() async {
    if (_videoPlayerController.value.isPlaying) {
      _chewieController.pause();
      super.setState(() {
        _showCover = true;
        canPlay = 1;
      });
    }
    else {
      super.setState(() {
        _showCover = false;
      });
      _chewieController.play();
      TTBase.longVideoAutoPlay = true;
    }
  }

  void readyPlay(bool canplay) async {
    if (!this.mounted) {
      return;
    }
    if (!canplay) {
      print('是否可以播放');
      int canPlayCheck = TTService.canPlay(widget.longVideoModel.id);
      if (canPlayCheck != 1) {
        TTBase.longVideoAutoPlay = false;
        setState(() {
          canPlay = canPlayCheck;
        });

        return;
      }
    }


    if (_chewieController == null) {
      print('播放器创建：' + longVideoModel.title);
      super.setState(() {
        _showCover = false;
      });

      _videoPlayerController = VideoPlayerController.network(
          TTBase.serverUrl + '/video/m3u8/' + longVideoModel.hash + '.m3u8');
      _videoPlayerController.addListener(() {


      });
      _videoPlayerController.initialize().then((value) {
        _chewieController = ChewieController(
          allowedScreenSleep: false,
          allowPlaybackSpeedChanging: false,
          showControlsOnInitialize: false,
          videoPlayerController: _videoPlayerController,
          showOptions: false,
          showControls: false,
          autoPlay: false,
          allowFullScreen: false,
          looping: true,


        );
        _videoPlayerController.addListener(() {
          if (showTitle && _videoPlayerController.value.isPlaying) {
            Wakelock.enable();
            Future.delayed(Duration(milliseconds: 3000), () {
              if (this.mounted) {
                setState(() {
                  showTitle = false;
                });
              }
            });
          }else if(!_videoPlayerController.value.isPlaying){  Wakelock.disable();}
        });


        playOrPause();
      });
    } else {
      playOrPause();
    }
  }

  void gotToPlayerPage() {
    print('进入详细页');
    Navigator.pushNamed(
        context, '/longvideo_player', arguments: {
      'longVideoModel': longVideoModel,
      'position': _videoPlayerController == null
          ? Duration.zero
          : _videoPlayerController.value.position,
      'followEvent': widget.followEvent
    }).then((value) {
      if (_chewieController == null) {
        return;
      }
      if (((value as Map<String, Object>)['longVideoModel'] as VideoModel)
          .hash == longVideoModel.hash) {
        if ((value as Map<String, Object>)['isPlaying']) {
          _chewieController.seekTo((value as Map<String, Object>)['position']);
          _showCover = false;
          _chewieController.play();
        } else {
          _chewieController.pause();
          _showCover = true;
          showTitle = true;
        }
      } else {
        _chewieController.pause();
        _showCover = true;
        showTitle = true;
      }
    });
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

  Future<bool> onFavoriteButtonTapped(bool isFavorite,
      VideoModel videoModel) async {
    if (!TTService.checkLogin(context)) {
      return isFavorite;
    }
    Future<Map> res;
    if (isFavorite) {
      res = TTService.removeFavorite(videoModel.hash, false, []);
      videoModel.ext_info.is_favorites = false;
      videoModel.ext_info.favorites_count =
          videoModel.ext_info.favorites_count - 1;
    }
    else {
      res = TTService.addFavorite(videoModel.hash);
      videoModel.ext_info.is_favorites = true;
      videoModel.ext_info.favorites_count =
          videoModel.ext_info.favorites_count + 1;
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

  Future<bool> onFollowButtonTapped(bool isFollow,
      VideoModel videoModel) async {
    if (!TTService.checkLogin(context)) {
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
        //通知上层列表修改所有当前用户的关注状态
        widget.followEvent(!isFollow, videoModel.ext_info.user_id);
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

  Future<bool> onLikeButtonTapped(bool isLike, VideoModel videoModel) async {
    if (!TTService.checkLogin(context)) {
      return isLike;
    }
    Future<Map> res;
    if (isLike) {
      res = TTService.removeLike(videoModel.hash);
      videoModel.ext_info.is_like = false;
      videoModel.ext_info.like_count = videoModel.ext_info.like_count - 1;
    }
    else {
      res = TTService.addLike(videoModel.hash);
      videoModel.ext_info.is_like = true;
      videoModel.ext_info.like_count = videoModel.ext_info.like_count + 1;
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

  Widget _newPlayer(_chewieController, _videoPlayerController1) {
    return
      Container(
          color: Colors.black,
          alignment: Alignment.center,
          height: TTBase.playerAndCoverHeight,
          child:
          Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: (_chewieController != null &&
                      _videoPlayerController != null)
                      ?
                  Chewie(
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


          ));
  }

  @override
  Widget build(BuildContext context) {
    return
      VisibilityDetector(key: Key('long_video_player_'+longVideoModel.hash), onVisibilityChanged: (visibilityInfo) {
    if(visibilityInfo.visibleFraction<=0.8&&_videoPlayerController!=null&&_videoPlayerController.value.isPlaying){

    _videoPlayerController.pause();setState(() {
      _showCover=true;
      showTitle=true;
    });
    }},child:
      Container(child:
      Column(
        children: [

          Container(height: TTBase.playerAndCoverHeight, child:
          InkWell(
              onTap: () {
                if (!_showCover) {
                  if (_videoPlayerController != null) {
                    _chewieController.pause();
                    _showCover = true;
                    showTitle = true;
                  }
                  gotToPlayerPage();
                } else {
                  scrollToCenter(500);
                }
              },
              child:
              Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  (
                      _showCover ? Container(color: Colors.black,) : _newPlayer(
                          _chewieController, _videoPlayerController)),
                  _showCover ? AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child:

                      Stack(fit: StackFit.expand, children: [

                        CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                            imageUrl: longVideoModel.image + '_1.dat',
                            cacheManager: CrpytImageCacheManager()),
                        Center(child: SvgPicture.asset(
                          'images/common/play.svg', height: 40, color: Colors
                            .white60,),),
                        Container(decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                                Colors.transparent
                              ],
                            ))),

                        Positioned(child: Row(children: [
                          Text(
                            TTService.formatNum(longVideoModel.played)
                                .toString() + '次播放',
                            style: TextStyle(color: Colors.white),),
                          Padding(padding: EdgeInsets.only(left: dp(16)),),
                          Container(
                            padding: EdgeInsets.only(left: dp(12),
                                right: dp(12),
                                top: dp(4),
                                bottom: dp(4)),
                            decoration: BoxDecoration(color: Colors.black26,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(dp(12)))),
                            child:
                            Text(
                              TTService.formateDuration(
                                  longVideoModel.duration),
                              style: TextStyle(color: Colors.white),),)
                        ]), bottom: dp(8), right: dp(8))
                      ],
                      ))
                      : Padding(
                    padding: EdgeInsets.zero,),
                  showTitle || _showCover ?
                  Positioned(child: Container(padding: EdgeInsets.only(
                      top: dp(8), left: dp(14)), child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(longVideoModel.title,
                          style: TextStyle(
                              color: Colors.white, fontSize: 16,height: 1.4),
                          maxLines: 2,))
                      ]),)) : Padding(padding: EdgeInsets.zero),
                  canPlay != 1 ? Stack(children: [
                    CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                        imageUrl: longVideoModel.image + '_1.dat',
                        cacheManager: CrpytImageCacheManager()),
                    Container(color: Colors.black.withOpacity(0.6),
                        child: CantPlay(canPlay: canPlay, playCallBack: () {
                          TTBase.localData.played_free =
                              TTBase.localData.played_free + 1;
                          TTBase.localData.played_videoids.add(
                              widget.longVideoModel.id);
                          TTService.saveLocalData();
                          setState(() {
                            canPlay = 1;
                          });
                          readyPlay(true);
                        },reCheck: (){
                          readyPlay(false);
                        },))
                  ]) : Padding(padding: EdgeInsets.zero)
                ],
              ))),
          InkWell(
              onTap: () {
                gotToPlayerPage();
              },
              child:
              Container(
                padding: EdgeInsets.only(
                    left: dp(16), top: dp(0), bottom: dp(0), right: dp(16)),
                child:
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child:
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/user',
                                    arguments: {
                                      'videoModel_ExtInfo': longVideoModel
                                          .ext_info,
                                      'followEvent': widget.followEvent
                                    });
                              },
                              child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    child:
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          32),
                                      child:
                                      Container(
                                          height: dp(32),
                                          width: dp(32),
                                          color: ThemeUtils
                                              .getLightBackgroundColor(context),
                                          child: CachedNetworkImage(
                                              fadeInDuration: Duration(milliseconds: 200),
                                              fit: BoxFit.cover,
                                              imageUrl: (TTBase.appConfig
                                                  .res_server +
                                                  'data/avatar/' +
                                                  TTService.generate_MD5(
                                                      longVideoModel.ext_info
                                                          .user_id
                                                          .toString()) +
                                                  '.dat'),
                                              cacheManager: CrpytAvatarCacheManager(),
                                              errorWidget: (
                                                  BuildContext context,
                                                  Object exception,
                                                  StackTrace) {
                                                return SvgPicture.asset(
                                                    'images/common/defaultavatar.svg',
                                                    height: dp(24),
                                                    width: dp(24),
                                                    color: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        .color
                                                        .withOpacity(0.4));
                                              })),
                                    ),
                                    // padding: EdgeInsets.only(top: dp(8),bottom: dp(8)),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: dp(8))),
                                  Text(longVideoModel.ext_info.user_name,
                                    textAlign: TextAlign.start,),
                                  Padding(
                                      padding: EdgeInsets.only(left: dp(4))),
                                  SizedBox(
                                    width: 1,
                                    height: dp(10),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.2)),
                                    ),
                                  ),
                                  following ? Lottie.asset(
                                      'asset/loading.json',
                                      height: dp(24), width: dp(24)

                                  ) :
                                  InkWell(
                                      onTap: () {
                                        following = true;
                                        setState(() {

                                        });
                                        onFollowButtonTapped(
                                            longVideoModel.ext_info.is_follow,
                                            longVideoModel);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              top: dp(16),
                                              bottom: dp(16),
                                              left: dp(4),
                                              right: dp(8)),
                                          child: Text(
                                            longVideoModel.ext_info.is_follow
                                                ? '已关注'
                                                : '关注', style: TextStyle(
                                              color: longVideoModel.ext_info
                                                  .is_follow
                                                  ? Theme
                                                  .of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .color
                                                  : Colours.app_main),)))
                                ],))),

                      Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(children: [
                                LikeButton(
                                  padding: EdgeInsets.only(top: dp(16),
                                      bottom: dp(16),
                                      right: dp(16)),
                                  isLiked: BlocObj.user.state['isLogin'] &&
                                      longVideoModel.ext_info.is_favorites,
                                  onTap: (bool isFavorite) {
                                    return onFavoriteButtonTapped(
                                        isFavorite, longVideoModel);
                                  },
                                  size: (22),
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
                                  likeCount: longVideoModel.ext_info
                                      .favorites_count,
                                  likeCountAnimationType: LikeCountAnimationType
                                      .none,
                                  countBuilder: (int count, bool isFavorite,
                                      String text) {
                                    return isFavorite ? Text(count.toString(),
                                      style: TextStyle(
                                          color: Colours.app_main),) : Text(
                                        count > 0 ? count.toString() : '收藏');
                                  },
                                ),
                              ]),
                              LikeButton(
                                onTap: (bool isLike) {
                                  return onLikeButtonTapped(
                                      isLike, longVideoModel);
                                },
                                padding: EdgeInsets.only(
                                    top: dp(16), bottom: dp(16)),
                                size: (22),
                                likeBuilder: (bool isLiked) {
                                  return isLiked
                                      ? SvgPicture.asset(
                                    'images/common/thumbup_clicked.svg',
                                    height: 16, color: Colours.app_main,)
                                      : SvgPicture.asset(
                                    'images/common/thumbup.svg', height: 16,
                                    color: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,);
                                },
                                isLiked: BlocObj.user.state['isLogin'] &&
                                    longVideoModel.ext_info.is_like,
                                likeCount: longVideoModel.ext_info.like_count,
                                likeCountAnimationType: LikeCountAnimationType
                                    .none,
                                countBuilder: (int count, bool isLiked,
                                    String text) {
                                  return isLiked ? Text(count.toString(),
                                    style: TextStyle(
                                        color: Colours.app_main),) : Text(
                                      count > 0 ? count.toString() : '点赞');
                                },
                              ),

                            ],
                          )),
                    ]
                ),
              )),
        ],

      )));
  }


}

