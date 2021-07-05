import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../res/colours.dart';
import '../../widget/recommend_follow.dart';
import '../../base.dart';
import '../../../service.dart';
import '../../bloc.dart';
import 'player.dart';
import '../../../models.dart';
class ShortVideoListPage extends StatefulWidget {
  bool is_follow=false;
  int offset=0;


  ShortVideoListPage(this.is_follow);
  @override
  State<StatefulWidget> createState() {
    return _ShortVideoListPageState();
  }
}
class _ShortVideoListPageState extends State<ShortVideoListPage> with TTBase,TickerProviderStateMixin {

  String errorMsg = '';
  PageController _pageController = PageController(keepPage: true);
  List<VideoModel> videoList;
  List<User>followList=null;
  @override
  void initState() {
    super.initState();
    loadMoreVideoList();
    loadFollowList();
    // TODO: implement initState

  }

  @override
  Widget build(BuildContext context) {

    if(widget.is_follow&&!BlocObj.user.state['isLogin']){
      return  Container(
          color: Colours.dark_bg_color,child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('登录后更懂你，内容更有趣',style: TextStyle(color: Colours.dark_text)),
          Padding(padding: EdgeInsets.only(top: dp(8)),),
          ElevatedButton(onPressed: () {
            Navigator.pushNamed(context, '/login').then((value)  {
             loadMoreVideoList();
             loadFollowList();
            });
          }, child: Text('登录'))
        ],));
    }
   else if (errorMsg.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(dp(16)),
          color: Colours.dark_bg_gray,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMsg, style: TextStyle(color: Colours.dark_text)),
              Padding(padding: EdgeInsets.only(top: dp(8)),),
              ElevatedButton(onPressed: () {
                setState(() {
                  errorMsg = '';
                  videoList = null;
                });
                loadMoreVideoList();
              }, child: Text('重新加载'))
            ],));
    }  else if(widget.is_follow&&followList!=null&&followList.length ==0) {
      //尚未关注任何人
      return Container(
          color: Colours.dark_bg_gray,
          child:RecommendFollowPage(darkMode: true, followEvent: () {
        setState(() {
          videoList = null;
        });
        loadFollowList();
        loadMoreVideoList();
      },));
    }
    return videoList == null ?
    Container(
        color: Colours.dark_bg_color,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
            children:[
                Lottie.asset(
                'asset/loading.json',
                height: dp(128),width: dp(128)

            ),])) : (videoList.length == 0? Container(  color: Colours.dark_bg_color,child: Center(child:Text(widget.is_follow?'暂无内容，去关注更多人吧':'暂无内容，去别的地方看看吧',style: TextStyle(color: Colours.dark_text),))) : PageView.builder(
      controller: _pageController,
      itemCount: videoList.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return Player(shortVideoModel: videoList[index] ,followEvent: (isFollow, user_id) {
          videoList.where((element) =>
          element.ext_info.user_id == user_id)
              .forEach((element) {
            element.ext_info.is_follow=isFollow;

          });
          setState(() {

          });
        });
      },
      onPageChanged: (index) {
        print('视频索引：' + index.toString() + ' 视频总数量：' +
            videoList.length.toString());
        if (index > videoList.length - 5) {
          loadMoreVideoList();
        }
      },
    ));
  }
  Future<void> loadFollowList() async {
    print('加载关注列表');
    if(followList!=null){followList.clear();}

    var res= await TTService.userFollow('update', 0,'');
    if(res['code']==1){ followList=[];
      (res['data']['follow'] as List).forEach((element) {
        User user=User.fromJson(element);
        followList.add(user);
      });
    }
    setState(() {

    });
  }
  Future<void> loadMoreVideoList() async {
    errorMsg='';
    var res ;
    if(widget.is_follow){
      res=await TTService.getFollowVideos(false,widget.offset);
    }else{
      res=await TTService.getVideoList(context, -1);
    }
    if (videoList == null) {
      videoList = [];
    }
    if (res['code'] == 1) {
      (res['data']['list'] as List).forEach((element) {
        VideoModel shortVideoModel = VideoModel.fromJson(element);
        shortVideoModel.image =TTBase.appConfig.res_server + element['image'];
        videoList.add(shortVideoModel);
      });
      widget.offset=videoList.length;
    } else {
      errorMsg = '加载失败：' + ((res['error']!=null)?res['error'].toString():'未知原因');
    }
    super.setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}