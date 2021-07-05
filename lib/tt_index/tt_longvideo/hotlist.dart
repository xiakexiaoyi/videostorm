import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import '../../../base.dart';
import '../../common/crpyt_image_cache_manager.dart';
import '../../models.dart';
import '../../service.dart';
import '../../res/colours.dart';

class LongVideoHotListPage extends StatefulWidget with TTBase {



  @override
  LongVideoHotListPageState createState() => LongVideoHotListPageState();

}

class LongVideoHotListPageState extends State<LongVideoHotListPage> with SingleTickerProviderStateMixin,TTBase,AutomaticKeepAliveClientMixin {

  RefreshController _refreshController = RefreshController(
      initialRefresh: false);
  ScrollController _scrollController = new ScrollController();
  List<VideoModel>videoList;
  String errorMsg = '';
  bool loading=false;


  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      //print(_scrollController.offset.toString()+'-'+_scrollController.position.maxScrollExtent.toString());
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 100) {

        _onLoading();
      }
    });
    if (videoList == null) {
      _onRefresh();
    }

  }

  void _onRefresh() async {

   loadVideoList(true);
  }

  void loadVideoList(bool clearData) async {
    if (loading) {
      return;
    }
    loading=true;

    var res = await TTService.getHotVideos(-2);
    if (videoList == null) {
      videoList = new List();
    }
    if (clearData) {
      videoList.clear();
    }
    if (res['code'] == 1) {
      if((res['data']['list'] as List).length==0){
        //没有更多了
        _refreshController.loadNoData();
      }
      (res['data']['list'] as List).forEach((element) {
        VideoModel videoModel = VideoModel.fromJson(element);
        videoModel.image = TTBase.appConfig.res_server + element['image'];
        videoList.add(videoModel);
      });

    } else {
      errorMsg = '视频加载失败：' +
          ((res['error'] != null) ? res['error'].toString() : '未知原因');
    }

    _refreshController.refreshCompleted();
    setState(() {});
    loading=false;
  }

  // 上拉加载
  void _onLoading() async {
  _refreshController.loadNoData();
  }

  @override
  Widget build(BuildContext context) {

      return  _longVideoList();


  }

  _longVideoList() {
    if (errorMsg.isNotEmpty) {
      return Container(padding: EdgeInsets.all(dp(16)),child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: EdgeInsets.all(dp(16)),child:Text(errorMsg)),
          Padding(padding: EdgeInsets.only(top: dp(8)),),
          ElevatedButton(onPressed: () {
            setState(() {
              errorMsg = '';
              videoList = null;
            });
            _onRefresh();
          }, child: Text('重新加载'))
        ],));
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
          ]) : (videoList.length == 0 ? Center(child: Text('暂无内容')) :
      Container(

        padding: EdgeInsets.only(left: dp(16), right: dp(16),top: dp(8)),
        color: Theme
            .of(context)
            .backgroundColor,
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
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: dp(20)),
                              color: Theme
                                  .of(context)
                                  .backgroundColor,
                              child:InkWell(onTap: (){

                                Navigator.pushNamed(
                                    context, '/longvideo_player', arguments:{'longVideoModel': videoList[index],'position':Duration.zero});
                              },child: _longVideoItem(videoList[index],index)),

                            );
                          }, addAutomaticKeepAlives: false,
                          childCount: videoList.length))

                ],
              ),
            ),
          ),
        ),
      ));
  }

  _longVideoItem(VideoModel videoModel,int index) {
    return
      Container(
          color: Theme
              .of(context)
              .backgroundColor,
          height: 108, child:

      Container(child:
      Row(children: [
        Expanded(child:
        Container(height: videoModel.category == -1
            ? TTBase.screenWidth / 1.2
            : TTBase.screenWidth / 2,
            width: videoModel.category == -1 ? TTBase.screenWidth / 1.8 : TTBase
                .screenWidth - dp(32),
            child: Stack(fit: StackFit.expand, children: [
              ClipRRect(borderRadius: BorderRadius.circular(4), child:
              CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                  imageUrl: videoModel.image + '_1.dat',
                  cacheManager: CrpytImageCacheManager())),

              Positioned(top:0,left: 0,child: Container(alignment: Alignment.center,padding: EdgeInsets.all(dp(2)),width: dp(36),decoration: new BoxDecoration(
                  color:index==0?Color(0xfffac458):(index==1?Color(0xffa1a2be):(index==2?Color(0xffb38273):Colors.black26)),
                borderRadius: BorderRadius.only(topLeft:Radius.circular(4.0),bottomRight: Radius.circular(4.0)),),child: Text(index<=2?'No.'+(index+1).toString():(index+1).toString(),style: TextStyle(color: Colors.white),))),
              Positioned(child: Row(children: [

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
            ))
        ),
        Expanded(child:
        Container(padding: EdgeInsets.only(left: dp(8)),alignment: Alignment.centerLeft, child:
        Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(alignment: Alignment.centerLeft,child: Text(videoModel.title,style: TextStyle(fontSize: 16,height: 1.4),maxLines: 2,overflow: TextOverflow.ellipsis,)),
            Padding(padding: EdgeInsets.only(top:dp(4))),
            Container(alignment: Alignment.centerLeft,child: Text(videoModel.ext_info.user_name,style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color,fontSize: 12),)),
            Padding(padding: EdgeInsets.only(top:dp(4))),
            Container(decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(2))),alignment: Alignment.centerLeft,child: Text(TTService.formatNum(videoModel.ext_info.like_count)+'点赞',style: TextStyle(color: Colours.app_main,fontSize: 12),)),
            Padding(padding: EdgeInsets.only(top:dp(8))),
            Container(alignment: Alignment.centerLeft,child:Text(TTService.formatTime((videoModel.add_time/1000).round())+'  '+TTService.formatNum(videoModel.played)+'次播放',style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color,fontSize: 12))),
          ],))),
      ],)));
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}