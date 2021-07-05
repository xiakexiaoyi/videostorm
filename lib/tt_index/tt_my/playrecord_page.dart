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
class PlayRecordPage extends StatefulWidget with TTBase {
  @override
  _PlayRecordPageState createState() => _PlayRecordPageState();
}

class _PlayRecordPageState extends State<PlayRecordPage> with SingleTickerProviderStateMixin,TTBase {

  RefreshController _refreshController = RefreshController(
      initialRefresh: false);
  ScrollController _scrollController = new ScrollController();
  List<VideoModel>videoList;
  String errorMsg = '';
  bool loading = false;
  int video_last_id = 0;
  bool deleteMode = false;
  List<String>deleteHashs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      //print(_scrollController.offset.toString()+'-'+_scrollController.position.maxScrollExtent.toString());
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 100) {
        _onLoading();
      }
    });
    if (videoList == null) {
      _onRefresh();
    }
  }

  void _onRefresh() async {
    video_last_id=0;
    loadVideoList(true);
    print('刷新全部数据');
  }

  void loadVideoList(bool clearData) async {
    if (loading) {
      return;
    }
    loading = true;
    var res = await TTService.historyList(
        context, video_last_id);
    if (videoList == null) {
      videoList = new List();
    }
    if (clearData) {
      print('clearData');
      videoList.clear();
    }
    if (res['code'] == 1) {
      (res['data']['histories'] as List).forEach((element) {
        VideoModel videoModel = VideoModel.fromJson(element);
        videoModel.image = TTBase.appConfig.res_server + element['image'];
        videoList.add(videoModel);
      });
      if (videoList.length > 0) {
        video_last_id = videoList.last.id;
      }
    } else {
      errorMsg = '视频加载失败：' +
          ((res['error'] != null) ? res['error'].toString() : '未知原因');
    }

    _refreshController.refreshCompleted();
    setState(() {});
    loading = false;
  }

  // 上拉加载
  void _onLoading() async {
    print('上拉加载更多');
    loadVideoList(false);
  }

  void deleteAllHistory() {
    _loadingCallBack(Function func) async {
      var res = await TTService.removeHistory('', true, []);
      if (res['code'] != 1) {
        func();
        Fluttertoast.showToast(msg: '清空失败' + (res['error'] != null
            ? '，' + res['error'].toString()
            : ''), toastLength: Toast.LENGTH_LONG);
      } else {
        func();
        videoList.removeWhere((item) => deleteHashs.contains(item.hash));
        deleteHashs.clear();
        deleteMode = false;
        _onRefresh();
        setState(() {

        });
      }
    }

    _okCallBack() {
      Future.delayed(Duration(milliseconds: 1), () {
        TTDialog.showLoading(
          context, title: '正在清空...', dismissDialog: _loadingCallBack,);
      });
    }
    TTDialog.showCustomDialog(context, text: '确定清空所有播放记录吗？清空后将永久无法找回，请谨慎操作。',
        yes: '清空',
        okCallBack: _okCallBack);
  }

  void deleteSelectedHistory() async {
    _loadingCallBack(Function func) async {
      var res = await TTService.removeHistory('', false, deleteHashs);
      if (res['code'] != 1) {
        func();
        Fluttertoast.showToast(msg: '删除失败' + (res['error'] != null
            ? '，' + res['error'].toString()
            : ''), toastLength: Toast.LENGTH_LONG);
      } else {
        func();
        videoList.removeWhere((item) => deleteHashs.contains(item.hash));
        deleteHashs.clear();
        setState(() {

        });
      }
    }

    _okCallBack() async {
      Future.delayed(Duration(milliseconds: 1), () {
        TTDialog.showLoading(
          context, title: '正在删除...', dismissDialog: _loadingCallBack,);
      });
    }

    TTDialog.showCustomDialog(
        context, text: '确定删除' + deleteHashs.length.toString() + '条播放记录吗？',
        yes: '删除',
        okCallBack: _okCallBack);
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
                  InkWell(
                      onTap: () {
                        deleteHashs.clear();
                        setState(() {
                          deleteMode = !deleteMode;
                        });
                      },
                      child:
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: dp(16), left: dp(16)),
                          child:
                          Text(deleteMode ? '取消' : '编辑',
                              style: TextStyle(color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1
                                  .color, fontSize: 16))))
                ],
                title: Text('播放记录', style: TextStyle(color: Theme
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
              body:Column(children: [
                Divider(),
                Expanded(child:   _list())
              ],) );
        });
  }

  _list() {
    if (errorMsg.isNotEmpty) {
      return Container(padding: EdgeInsets.all(dp(16)),child:Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center,
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
        ],)));
    }
    return
      videoList == null ?
      Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(alignment: Alignment.center, child:
            Lottie.asset(
                'asset/loading.json',
                height: dp(96), width: dp(96)

            )),
          ]) : (videoList.length == 0 ? Center(child: Text('尚未观看过任何内容')) :
      Container(


          color: Theme
              .of(context)
              .scaffoldBackgroundColor,
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
                                  margin: EdgeInsets.only(bottom: dp(8)),
                                  color: Theme
                                      .of(context)
                                      .backgroundColor,
                                  child: InkWell(onTap: () {
                                    if (deleteMode) {
                                      if (deleteHashs.contains(
                                          videoList[index].hash)) {
                                        deleteHashs.remove(
                                            videoList[index].hash);
                                      } else {
                                        deleteHashs.add(videoList[index].hash);
                                      }
                                      setState(() {

                                      });
                                    }
                                  }, child: _item(videoList[index])),

                                );
                              }, addAutomaticKeepAlives: false,
                              childCount: videoList.length))

                    ],
                  ),
                ),
              ),
            ),
            deleteMode ? Positioned(bottom: 0, child:
            Container(child: Row(
                children: [

                  Container(color: Theme
                      .of(context)
                      .backgroundColor,
                    width: TTBase.screenWidth,
                    child: Row(children: [
                      Expanded(child:
                      InkWell(onTap: () {
                        deleteAllHistory();
                      }, child:
                      Container(
                          padding: EdgeInsets.only(top: dp(16), bottom: dp(16)),
                          alignment: Alignment.center,
                          child: Text(
                            '一键清空', style: TextStyle(fontSize: 16),)))),
                      SizedBox(
                        width: 0.5,
                        height: dp(24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .subtitle2
                                  .color
                                  .withOpacity(0.2)),
                        ),
                      ),
                      Expanded(child: InkWell(onTap: () {
                        if (deleteHashs.length > 0) {
                          deleteSelectedHistory();
                        }
                      }, child: Container(
                          padding: EdgeInsets.only(top: dp(16), bottom: dp(16)),
                          alignment: Alignment.center,
                          child: Text(deleteHashs.length > 0 ? '删除(' +
                              deleteHashs.length.toString() + ')' : '删除',
                            style: TextStyle(
                                fontSize: 16, color: Colours.app_main),)))),
                    ],),)


                ]
            ),),

            ) : Padding(padding: EdgeInsets.zero,)
          ],)

      ));
  }

  _item(VideoModel videoModel) {
    return
      Container(
          padding: EdgeInsets.only(left: dp(16),right: dp(16),top: dp(16),bottom: dp(16)),
          color: Theme
              .of(context)
              .backgroundColor,
          child:
          Row(children: [
//        Container(width: dp(64),child:
//        Checkbox(value: false,  onChanged: (value){},activeColor: Colours.app_main)),
            deleteMode ? Container(padding: EdgeInsets.only(right: dp(16)), child:
            deleteHashs.contains(videoModel.hash) ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(

                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    color: Colours.app_main,
                    child:
                    Checkbox(
                      shape: CircleBorder(side: BorderSide.none),
                      checkColor: Colors.white,
                      activeColor: Colours.app_main,
                      value: true,
                      onChanged: (value) {
                        setState(() {

                        });
                      },
                    )
                )) : Container(height: dp(22),
                width: dp(22),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(
                    Radius.circular(dp(12))), border: Border.all(color: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .color, width: 1.0))),
            ) : Padding(padding: EdgeInsets.zero),
            Expanded(child:
            Column(mainAxisAlignment: MainAxisAlignment.start,children: [
    InkWell(onTap: (){
    Navigator.pushNamed(context, '/user',arguments: {'videoModel_ExtInfo':videoModel.ext_info});
    },child:
              Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      24),
                  child:
                  Container(
                      height: dp(32),
                      width: dp(32),
                      color: ThemeUtils.getLightBackgroundColor(context),
                      child: CachedNetworkImage(
                          fadeInDuration: Duration(milliseconds: 200),
                          fit: BoxFit.cover,
                          imageUrl: (TTBase.appConfig
                              .res_server +
                              'data/avatar/' +
                              TTService.generate_MD5(
                                  videoModel.ext_info.user_id
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
                                  .textTheme.subtitle2.color.withOpacity(0.4),);
                          })),
                ),
                Padding(padding: EdgeInsets.only(left: dp(8))),
                Expanded(child:
                Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,children: [
                  Container(child: Text(videoModel.ext_info.user_name,style:TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.only(top: dp(4))),
                  Text(TTService.formatTime((videoModel.add_time/1000).round()),style: TextStyle(fontSize: 12,color: Theme.of(context).textTheme.subtitle2.color),),
                ],))
              ],)),
              Padding(padding: EdgeInsets.only(top: dp(8))),
              Container(alignment: Alignment.centerLeft,child:Text(videoModel.title,style:TextStyle(fontSize: 16))),
              Padding(padding: EdgeInsets.only(top: dp(8))),
              Row(children:[
                InkWell(onTap: (){
                  if(!deleteMode){
                    if(videoModel.category==-1){
                      //短视频
                      Navigator.pushNamed(
                          context, '/shortvideo_player', arguments:{'videoModel': videoModel});
                    }else{
                      Navigator.pushNamed(
                          context, '/longvideo_player', arguments:{'longVideoModel': videoModel,'position':Duration.zero});
                    }
                  }else{
                    if (deleteHashs.contains(
                        videoModel.hash)) {
                      deleteHashs.remove(
                          videoModel.hash);
                    } else {
                      deleteHashs.add(videoModel.hash);
                    }
                    setState(() {

                    });
                  }
                },child:
                Container(height: videoModel.category==-1?TTBase.screenWidth/1.2:TTBase.screenWidth/2,width:videoModel.category==-1?TTBase.screenWidth/1.8:TTBase.screenWidth-dp(32),child:Stack(fit: StackFit.expand, children: [
                  ClipRRect( borderRadius: BorderRadius.circular(videoModel.category==-1?0:4),child:
                  CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                      imageUrl: videoModel.image + '_1.dat',
                      cacheManager: CrpytImageCacheManager())),
                  Center(child: SvgPicture.asset(
                    'images/common/play.svg', height: 40, color: Colors
                      .white60,),),


                  Positioned(child: Row(children: [
                    Text(
                      TTService.formatNum(videoModel.played).toString() + '次播放',
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
                        TTService.formateDuration(videoModel.duration), style: TextStyle(color: Colors
                          .white),),)
                  ]), bottom: dp(8), right: dp(8))
                ],
                )))])

            ],)),
//        Container(margin: EdgeInsets.only(bottom: dp(8)),width: dp(160),child:
//        Stack(fit: StackFit.expand, children: [
//          ClipRRect(
//              borderRadius: BorderRadius.circular(4),
//              child:
//              CachedNetworkImage(fit: BoxFit.cover,
//                  imageUrl: videoModel.image + '_1.dat',
//                  cacheManager: CrpytImageCacheManager())),
//          Center(child: SvgPicture.asset(
//            'images/common/play.svg', height: 40, color: Colors
//              .white60,),),
//
//          Positioned(child: Row(children: [
//
//            Padding(padding: EdgeInsets.only(left: dp(16)),),
//            Container(
//              child:
//              Text(
//                formatDate(DateTime.fromMillisecondsSinceEpoch(videoModel
//                    .duration * 1000), videoModel.duration >= 3600 ? [
//                  HH,
//                  ':',
//                  mm,
//                  ':',
//                  ss
//                ] : [mm, ':', ss]), style: TextStyle(color: Colors.white),),)
//          ]), bottom: dp(8), right: dp(8))
//        ],
//        ),),
//        Expanded(child:
//        Container(padding: EdgeInsets.only(left: dp(8),right: dp(0)),child:
//        Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,children: [
//
//          Expanded(child:  Container(alignment: Alignment.bottomLeft,child: Text(videoModel.title))),
//          Padding(padding: EdgeInsets.only(top: dp(8))),
//          Expanded(child:  Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
//            videoModel.category==-1?Text('短视频',style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color)):Text('长视频',style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color)),
//            Padding(padding: EdgeInsets.only(left: dp(8))),
//            Text(videoModel.ext_info.user_name,style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color),)
//          ],))
//        ],),))

//      Column(children: [
//        Text(videoModel.title)
//      ],)
          ],)
      );
  }
}