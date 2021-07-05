import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock/wakelock.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:like_button/like_button.dart';
import 'package:share/share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/crpyt_image_cache_manager.dart';
import '../../models.dart';
import '../../widget/cant_play.dart';
import '../../widget/shadowtext.dart';
import '../../res/colours.dart';
import '../../bloc.dart';
import '../../service.dart';
import '../../base.dart';



///视频播放列表组件
// ignore: must_be_immutable
class Player extends StatefulWidget {
  VideoModel shortVideoModel;
  var followEvent;
  Player({Key key, @required this.shortVideoModel,this.followEvent });

  @override
  _PlayerState createState() {
    return _PlayerState();
  }
}

class _PlayerState extends State<Player> with TTBase,SingleTickerProviderStateMixin{
  bool _playing = false;
  VideoPlayerController _videoController;
  var _chewieController;
  StreamSubscription currentPosListener;
  AnimationController controller;
  CurvedAnimation curve;
  bool _visible=true;
  bool following=false;
  int canPlay=1;
  bool _showCover=true;
  double player_position=null;
  Timer timer_videoHistory;
  _PlayerState();
  @override
  void initState() {
    print('player initState');
    super.initState();
    checkPlay();
    timer_videoHistory = Timer.periodic(Duration(seconds: 5), (Timer t) =>
    {

      videoHistory()

    });

  }
  playVideo(){
    _videoController = VideoPlayerController.network(TTBase.serverUrl + '/video/m3u8/' + widget.shortVideoModel.hash+'.m3u8');
    _videoController.addListener(() {
      if(_videoController.value.isPlaying){
        Wakelock.enable();
      }else{
        Wakelock.disable();
      }
      if(_videoController.value.isInitialized){
        setState(() {
          _visible = false;


        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          if(this.mounted) {
            setState(() {
              _showCover = false;
            });
          }
        });
      }
      setState(() {

        player_position=_videoController.value.position.inMilliseconds/_videoController.value.duration.inMilliseconds;
        if(player_position.toString().toLowerCase()=='nan'){
          print('播放进度计算错误');
          player_position=null;
        }

      });


    });
    _videoController.initialize().then((value) {
      _chewieController = ChewieController(
        allowedScreenSleep: false,
        allowPlaybackSpeedChanging: false,
        showControlsOnInitialize: false,
        showControls: false,
        allowFullScreen: false,
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: true,
      );
    });
  }
  checkPlay(){
    canPlay = TTService.canPlay(widget.shortVideoModel.id);
    if (canPlay != 1) {
      setState(() {

      });
    } else {
      playVideo();
    }
  }
  void videoHistory()async{
    if(this.mounted && _videoController != null&&_videoController.value.isInitialized&&_videoController.value.isPlaying) {
      Wakelock.enable();
      TTService.addHistory(widget.shortVideoModel.hash,_videoController.value.position.inMilliseconds/_videoController.value.duration.inMilliseconds);
    }
  }
  @override
  void dispose() {
    print('播放器释放');
    Wakelock.disable();
    super.dispose();
    if (timer_videoHistory != null) {
      timer_videoHistory.cancel();
    }
    currentPosListener?.cancel();
    _videoController?.dispose();
    _chewieController?.dispose();

  }
  Future<bool> onFavoriteButtonTapped(bool isFavorite) async {


    if (!TTService.checkLogin(context)) {
      return isFavorite;
    }
    Future<Map> res;
    if (isFavorite) {
      res = TTService.removeFavorite(widget.shortVideoModel.hash,false,[]);
      widget.shortVideoModel.ext_info.is_favorites = false;
      widget.shortVideoModel.ext_info.favorites_count =
          widget.shortVideoModel.ext_info.favorites_count - 1;
    }
    else {
      res = TTService.addFavorite(widget.shortVideoModel.hash);
      widget.shortVideoModel.ext_info.is_favorites = true;
      widget.shortVideoModel.ext_info.favorites_count =
          widget.shortVideoModel.ext_info.favorites_count + 1;
    }
    res.then((value) {
      if (value['code'] == 1) {
        if (!isFavorite) {


        }
      }
      else {
        Fluttertoast.showToast(
            msg: isFavorite ? '收藏失败，' : '取消收藏失败，' + value['error'] == null
                ? '未知'
                : value['error'].toString(), toastLength: Toast.LENGTH_LONG);

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
      res = TTService.removeLike(widget.shortVideoModel.hash);
      widget.shortVideoModel.ext_info.is_like = false;
      widget.shortVideoModel.ext_info.like_count =
          widget.shortVideoModel.ext_info.like_count - 1;
    }
    else {
      res = TTService.addLike(widget.shortVideoModel.hash);
      widget.shortVideoModel.ext_info.is_like = true;
      widget.shortVideoModel.ext_info.like_count =
          widget.shortVideoModel.ext_info.like_count + 1;
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
          widget.shortVideoModel.ext_info.is_follow = !isFollow;
        });
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
  Widget _player(_chewieController,_videoPlayerController1){
    return
      VisibilityDetector(key: Key('short_video_player_'+widget.shortVideoModel.hash), onVisibilityChanged: (visibilityInfo) {
       if(visibilityInfo.visibleFraction==0&&_videoController!=null&&_videoController.value.isPlaying){

         _videoController.pause();
       }
      },child:
      Container(
          color: Colors.black,
          alignment: Alignment.center,
          height: TTBase.playerAndCoverHeight,
          child:
          Column(
            children: <Widget>[
              Expanded(
                child:
                 Center(
                  child: _chewieController != null &&
                      _chewieController
                          .videoPlayerController.value.isInitialized
                      ? Chewie(
                    controller: _chewieController,
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                     // CircularProgressIndicator(color: Colours.app_main,),
                    ],
                  ),
                ),
              ),




            ],


          )));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            _player(_chewieController,_videoController),
            _showCover ? AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child:
                CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.fitWidth,
                    imageUrl: widget.shortVideoModel.image + '_1.dat',
                    cacheManager: CrpytImageCacheManager())) :
           InkWell(
               onTap: ()
           {
             if(_videoController!=null&&_videoController.value.isInitialized&_videoController.value.isPlaying){
               //播放中
               _videoController.pause();
             }else if(_videoController!=null&&_videoController.value.isInitialized&!_videoController.value.isPlaying){
               _videoController.play();
             }
           },child: Container(
             child:_videoController!=null&&_videoController.value.isInitialized&!_videoController.value.isPlaying?
           Center(child: SvgPicture.asset(
             'images/common/play.svg', height: 64, color: Colors.white70,),)
               :Padding(padding: EdgeInsets.zero,))),
            Positioned(
              left: dp(16),
              bottom: dp(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                ShadowText(
                  '@'+ widget.shortVideoModel.ext_info.user_name, style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                Padding(padding: EdgeInsets.only(bottom: dp(8))),
                Container(width: TTBase.screenWidth/1.5,child:ShadowText(widget.shortVideoModel.title,maxLines: 2,
                    style: TextStyle(color: Colors.white, fontSize: 14,height: dp(1.4)))),
                Padding(padding: EdgeInsets.only(bottom: dp(0))),

                  Container(
                      width: MediaQuery.of(context).size.width/2,
                      child:
                   _tags(),),
              ],),
            ),
            Positioned(child: _rightButtons(),bottom: dp(24),right: dp(8),),
           canPlay!=1?Padding(padding: EdgeInsets.zero): Positioned(child:InkWell(
              onTap: (){
                print('点击进度条');
              },
                onTapDown: (TapDownDetails details){
                  print('点击进度条');
                  if(_videoController.value.isInitialized){
                    _videoController.seekTo(new Duration( milliseconds: (_videoController.value.duration.inMilliseconds*(details.localPosition.dx/TTBase.screenWidth)).round()));
                  }
                },
                child:Container(height: dp(24),padding: EdgeInsets.only(top:dp(17),bottom: dp(6),left: dp(0),right: dp(0)),child:LinearProgressIndicator(
                  value: player_position==double.nan?1:player_position,
              color: Colours.text_gray,backgroundColor: Colours.dark_bg_color,
            ))),bottom: dp(0),width: TTBase.screenWidth,),
            canPlay != 1 ?Stack(fit:StackFit.passthrough,
                children: [

                 Container(color: Colors.black.withOpacity(0.8),
                      child: CantPlay(
                        canPlay: canPlay, playCallBack: () {
                        TTBase.localData.played_free = TTBase.localData
                            .played_free + 1;
                        TTBase.localData.played_videoids.add(
                            widget.shortVideoModel.id);
                        TTService.saveLocalData();
                        setState(() {
                          canPlay = 1;
                        });
                        playVideo();
                      },reCheck: (){
                          checkPlay();
                      },))
                ]):Padding(padding: EdgeInsets.zero)
          ],
        ));
  }
  Widget _tags() {
    if(widget.shortVideoModel.tags == null){
      return Container();
    }
    List<Widget> tagsWidget=[];
    widget.shortVideoModel.tags.forEach((value) {
      tagsWidget.add(Container(
        margin: EdgeInsets.only(right: dp(8),top: dp(8)),
        padding: EdgeInsets.only(left:dp(6),right: dp(6),top:dp(4),bottom: dp(4)),
        decoration: new BoxDecoration(
          color:Colours.bg_color.withOpacity(0.1),
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          //设置四周边框
        ),
        child: Text(value,
          style: TextStyle(fontSize: 12,color: Colours.text_gray),),),);
    });
    return Container(child: Align(alignment: Alignment.topLeft,child: Wrap(direction:  Axis.horizontal,crossAxisAlignment: WrapCrossAlignment.start,alignment: WrapAlignment.start,children: tagsWidget)));

  }
  _rightButtons() {
    return Column(children: [
        InkWell(
        onTap: () {
      Navigator.pushNamed(context, '/user',arguments:{'videoModel_ExtInfo':widget.shortVideoModel.ext_info,'followEvent':widget.followEvent});
    },
    child:
      Container(height: dp(72),child:
Stack(children:[
       Container(
        width: dp(64),
        height: dp(64),
        decoration: BoxDecoration(
          border: new Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
          color: Colours.dark_bg_gray_
        ),
        child:ClipRRect( borderRadius: BorderRadius.circular(
            64),child:CachedNetworkImage(
            fadeInDuration: Duration(milliseconds: 200),
            fit: BoxFit.cover,
            imageUrl: (TTBase.appConfig
                .res_server +
                'data/avatar/' +
                TTService.generate_MD5(
                    widget.shortVideoModel.ext_info.user_id
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
      ),


         following?
    Positioned(child: Container(
    decoration: new BoxDecoration(
//背景
    color: Colors.white,
    //设置四周圆角 角度
    borderRadius: BorderRadius.all(Radius.circular(16.0)),),
        child: Lottie.asset(
        'asset/loading.json',height: dp(28),width: dp(28))),left:dp(18),bottom: 0,)

        :  widget.shortVideoModel.ext_info.is_follow?
    Positioned(child:InkWell(onTap: (){
      setState(() {
        following=true;
      });
      onFollowButtonTapped(widget.shortVideoModel.ext_info.is_follow,widget.shortVideoModel);

    }, child: Container(
      padding: EdgeInsets.only(left: dp(4),right: dp(4),top: dp(2),bottom: dp(2)),
    decoration:BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
           child: Text('已关注',style: TextStyle(color: Theme
        .of(context)
        .textTheme
        .subtitle2
        .color),)),
         ),bottom: 0,left: dp(7),)
         :
 Positioned(child:InkWell(
     onTap: (){
       setState(() {
         following=true;
       });
       onFollowButtonTapped(widget.shortVideoModel.ext_info.is_follow,widget.shortVideoModel);
     },
     child:
     Container(decoration: BoxDecoration(
   color: Colours.app_main,
    shape: BoxShape.circle,
    ),child:Container(padding: EdgeInsets.all(dp(8)),child:
 SvgPicture.asset(
    'images/common/follow.svg', height: 12, color: Colors.white,),))),left: dp(19),bottom: 0,)
]))),
      Padding(padding: EdgeInsets.only(top:dp(16))),
      Container(height: dp(64),child:
      LikeButton(
        onTap: (bool isLike) {
          return onFavoriteButtonTapped(isLike);
        },
        size: dp(28),
        likeBuilder: (bool isLiked) {
          return isLiked ? SvgPicture.asset(
            'images/common/favorite_clicked.svg', height: 16,
            color: Colours.app_main,) : SvgPicture.asset(
              'images/common/favorite_clicked.svg', height: 16, color: Colors.white.withOpacity(0.8));
        },
        isLiked: BlocObj.user.state['isLogin'] &&
            widget.shortVideoModel.ext_info.is_favorites,
        likeCount: widget.shortVideoModel.ext_info.favorites_count,
        likeCountAnimationType: LikeCountAnimationType.none,
        countBuilder: (int count, bool isLiked, String text) {
          return isLiked
              ? Text(count.toString(),
              style: TextStyle(color: Colours.app_main, height: dp(1)))
              : Text(count > 0 ? count.toString() : '收藏',style: TextStyle(color:  Colors.white),);
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
      )),
      Padding(padding: EdgeInsets.only(top:dp(6))),
    Container(height: dp(64),child:

    LikeButton(
      onTap: (bool isLike) {
        return onLikeButtonTapped(isLike);
      },
      size: dp(28),
      likeBuilder: (bool isLiked) {
        return isLiked ? SvgPicture.asset(
          'images/common/thumbup_clicked.svg', height: 16,
          color: Colours.app_main,) : SvgPicture.asset(
            'images/common/thumbup_clicked.svg', height: 16, color: Colors.white.withOpacity(0.8));
      },
      isLiked: BlocObj.user.state['isLogin'] &&
          widget.shortVideoModel.ext_info.is_like,
      likeCount: widget.shortVideoModel.ext_info.like_count,
      likeCountAnimationType: LikeCountAnimationType.none,
      countBuilder: (int count, bool isLiked, String text) {
        return isLiked
            ? Text(count.toString(),
            style: TextStyle(color: Colours.app_main, height: dp(1)))
            : Text(count > 0 ? count.toString() : '点赞',style: TextStyle(color:  Colors.white),);
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
    )),
      Padding(padding: EdgeInsets.only(top:dp(10))),
    Container(height: dp(64),child:
      InkWell(
    onTap: () {
    Share.share('【'+TTBase.appName+'推荐】' + widget.shortVideoModel.title+' https://www.baidu.com');
    },
    child:
    Padding(padding: EdgeInsets.only(top: dp(2)), child: Column(
    children: [
    SvgPicture.asset(
    'images/common/share_flat.svg', height: dp(28), color:  Colors.white.withOpacity(0.8)),
    Padding(padding: EdgeInsets.only(top: dp(4)),),
    Text('分享',style: TextStyle(color:  Colors.white),),
    ],))))

    ],);
  }



}
