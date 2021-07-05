import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../base.dart';
import '../../res/colours.dart';
import '../../../service.dart';
import 'player.dart';
import '../../../models.dart';
class ShortVideoPlayerPage extends StatefulWidget {
  final arguments;
  ShortVideoPlayerPage({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ShortVideoPlayerPageState();
  }
}
class _ShortVideoPlayerPageState extends State<ShortVideoPlayerPage> with TTBase,TickerProviderStateMixin {

  String errorMsg = '';
  PageController _pageController = PageController(keepPage: true);
  List<VideoModel> videoList;
  VideoModel videoModel;
  @override
  void initState() {
    videoModel = (widget.arguments as Map<String, Object>)['videoModel'];
    videoList=[];
    videoList.add(videoModel);
    super.initState();
    loadMoreVideoList();
    // TODO: implement initState

  }

  @override
  Widget build(BuildContext context) {
    print(errorMsg);
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(child:Scaffold(body:
        Stack(children:[
        _body(),
         InkWell(onTap: (){Navigator.pop(context);},child: Container(padding: EdgeInsets.only(top:TTBase.statusBarHeight+dp(16),left: dp(16)),child:  SvgPicture.asset('images/common/close.svg',height: dp(14),color: Colors.white,))),
         Positioned(right: 0,child: InkWell(onTap: (){Navigator.pop(context);Navigator.pushNamed(context, '/search');},child: Container(padding: EdgeInsets.only(top:TTBase.statusBarHeight+dp(16),right: dp(16)),child:  SvgPicture.asset('images/common/search.svg',height: dp(22),color: Colors.white,))))
            ]),)));
  }
_body(){
  if (errorMsg.isNotEmpty) {
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

            ),])) : (videoList.length == 0 ? Container(  color: Colours.dark_bg_color,child: Center(child:Text('暂无内容',style: TextStyle(color: Colours.dark_text),))) : PageView.builder(
    controller: _pageController,
    itemCount: videoList.length,
    scrollDirection: Axis.vertical,
    itemBuilder: (context, index) {
      return


          Player(shortVideoModel: videoList[index] ,followEvent: (isFollow, user_id) {
            videoList.where((element) =>
            element.ext_info.user_id == user_id)
                .forEach((element) {
              element.ext_info.is_follow=isFollow;

            });
            setState(() {

            });
          });},
    onPageChanged: (index) {
      print('视频索引：' + index.toString() + ' 视频总数量：' +
          videoList.length.toString());
      if (index > videoList.length - 5) {
        loadMoreVideoList();
      }
    },
  ));
}
  Future<void> loadMoreVideoList() async {
    var res = await TTService.getVideoList(context, -1);
    if (videoList == null) {
      videoList = [];
    }
    if (res['code'] == 1) {
      (res['data']['list'] as List).forEach((element) {
        VideoModel shortVideoModel = VideoModel.fromJson(element);
        shortVideoModel.image = res['data']['res_server'] + element['image'];
        videoList.add(shortVideoModel);
      });
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