import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import '../../service.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/crpyt_image_cache_manager.dart';
import '../../models.dart';
import '../../../base.dart';

class SearchResultPage extends StatefulWidget with TTBase {
   String keyword;
   bool long;
   String sort='default';
   int offset=0;

  SearchResultPage(Key key,this.keyword,this.long,this.sort): super(key: key);
  @override
  SearchResultPageState createState() => SearchResultPageState();

}

class SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin,TTBase,AutomaticKeepAliveClientMixin {

  RefreshController _refreshController = RefreshController(
      initialRefresh: false);
  ScrollController _scrollController = new ScrollController();
  List<VideoModel>videoList;
  String errorMsg = '';
  bool loading=false;


  @override
  void initState() {
    print('搜索关键词：'+widget.keyword);
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
void reSearch (keyword,long,sort)async {
  widget.keyword = keyword;
  widget.long = long;
  widget.sort = sort;
  widget.offset = 0;
  _refreshController.resetNoData();
  setState(() {
    videoList = null;
  });
  _onRefresh();
}
  void _onRefresh() async {
    widget.offset=0;
    loadVideoList(true);
    print('刷新全部数据');
  }

  void loadVideoList(bool clearData) async {
    if (loading) {
      return;
    }
    loading=true;

    var res = await TTService.videoSearch(widget.keyword,widget.sort,widget.long,widget.offset);
    if (videoList == null) {
      videoList = new List();
    }
    if (clearData) {
      print('clearData');
      widget.offset=0;
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
      });if(videoList.length>0) {
        widget.offset = videoList.length + 1;
      }

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
    print('上拉加载更多');
    loadVideoList(false);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.long){
      return  _longVideoList();
    }
   else{ return  _shortVideoList();}

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
          ]) : (videoList.length == 0 ? Center(child: Text('未能搜索到“'+widget.keyword+'”相关的内容')) :
      Container(

        padding: EdgeInsets.only(left: dp(16), right: dp(16)),
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
                              margin: EdgeInsets.only(top: dp(16)),
                              color: Theme
                                  .of(context)
                                  .backgroundColor,
                              child:InkWell(onTap: (){

                                Navigator.pushNamed(
                                    context, '/longvideo_player', arguments:{'longVideoModel': videoList[index],'position':Duration.zero});
                              },child: _longVideoItem(videoList[index])),

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
  _shortVideoList() {
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
          ]) : (videoList.length == 0 ? Center(child: Text('未能搜索到“'+widget.keyword+'”相关的内容')) :
      Container(


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
                  SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing:1,
                mainAxisSpacing: 1,
                childAspectRatio:0.6,
              ), delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.only(top: dp(0)),
                              color: Theme
                                  .of(context)
                                  .backgroundColor,
                              child:InkWell(onTap: (){
                                Navigator.pushNamed(
                                    context, '/shortvideo_player', arguments:{'videoModel': videoList[index]});
                              },child: _shortVideoItem(videoList[index])),

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
  _shortVideoItem(VideoModel videoModel) {
    return
      Container(
          color: Theme
              .of(context)
              .backgroundColor,
          height: 128, child:

        Container(child:
        Stack(fit: StackFit.expand, children: [

              CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                  imageUrl: videoModel.image + '_1.dat',
                  cacheManager: CrpytImageCacheManager()),

          Positioned(
              child: Container(
                padding: EdgeInsets.only(bottom: dp(8),top: dp(24),left: dp(4),right: dp(4)),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent ,
                          Colors.black,
                        ],
                      )),
              child:

              Column(mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.start,children: [
          Container( margin: EdgeInsets.only(left: dp(4),right: dp(4),bottom: dp(4)),width: TTBase.screenWidth/2-dp(16),child:  Text(videoModel.title,softWrap: true,style: TextStyle(color: Colors.white,fontSize: 16),)),
          Container( width: TTBase.screenWidth/2-dp(16),child: Row(mainAxisAlignment: MainAxisAlignment.start,children: [

               Container(

                 child:
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
                                   videoModel.ext_info
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
                                   .backgroundColor,);
                           })),
                 ),
                 // padding: EdgeInsets.only(top: dp(8),bottom: dp(8)),
               ),
               Padding(
                   padding: EdgeInsets.only(left: dp(4))),
               Text(videoModel.ext_info.user_name,
                 textAlign: TextAlign.start,style: TextStyle(color: Colors.white70,fontSize: 12),),
           Expanded(child:Container(alignment: Alignment.centerRight,child:
              SvgPicture.asset('images/common/thumbup.svg',width: dp(12),color: Colors.white70,)
            ,)),
            Padding(
                padding: EdgeInsets.only(left: dp(4))),
            Text(TTService.formatNum(videoModel.ext_info.like_count),style: TextStyle(color: Colors.white70,fontSize: 12)),
             ],))  ,
          ],)),bottom: 0,)
       ]
        )));
  }
  _longVideoItem(VideoModel videoModel) {
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
            Padding(padding: EdgeInsets.only(top:dp(8))),
            Container(alignment: Alignment.centerLeft,child:Text(TTService.formatTime((videoModel.add_time/1000).round())+'  '+TTService.formatNum(videoModel.played)+'次播放',style: TextStyle(color: Theme.of(context).textTheme.subtitle2.color,fontSize: 12))),
          ],))),
      ],)));
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}