import 'dart:io';

import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../base.dart';
import '../../res/colours.dart';
import '../../../service.dart';
import '../../../models.dart';
class VideoUploadIndexPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _VideoUploadIndexPageState();
  }
}
class _VideoUploadIndexPageState extends State<VideoUploadIndexPage> with TTBase,TickerProviderStateMixin {
String videoFileName;
ImagePicker imagePicker;

  @override
  void initState() {

    super.initState();
    imagePicker = new ImagePicker();
  }
selectedVideo(){
    print('视频文件：'+videoFileName);
    Navigator.pushNamed(context, '/upload/upload',arguments: {'videoFileName':videoFileName});
}
  @override
  Widget build(BuildContext context) {
    return
      Container(color: Theme
          .of(context)
          .scaffoldBackgroundColor, child:
      Container(decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x08f04142),
            Color(0x0822f2ff),
          ],
        ),
      ), child:
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,
            leadingWidth: dp(32),
            leading: InkWell(onTap: () {
              Navigator.pop(context);
            },
                child: Container(

                    padding: EdgeInsets.only(left: dp(16)),
                    child: SvgPicture.asset(
                      'images/common/close.svg', height: dp(24), color: Theme
                        .of(context)
                        .textTheme
                        .bodyText1
                        .color,))),
          ),
          body:
          Container(padding: EdgeInsets.fromLTRB(dp(16), dp(64), dp(16), 0),
            child: Column(children: [
              Expanded(child: Column(children: [
                Container(alignment: Alignment.centerLeft,
                    child: Text('Hi，开启创作之旅吧', style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold),)),
                Padding(padding: EdgeInsets.only(top: dp(8))),
                Container(
                    alignment: Alignment.centerLeft, child: Text('上传视频赚收益~')),
                Padding(padding: EdgeInsets.only(top: dp(16))),
                InkWell(onTap: ()  {
                  imagePicker.getVideo(
                      source: ImageSource.camera).then((value){
                    videoFileName=value.path;
                    selectedVideo();
                  });
                }, child:
                Container(child: Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'images/user/banner.jpg', height: dp(200),
                        fit: BoxFit.cover,
                        width: TTBase.screenWidth - dp(32),)),
                  Positioned.fill(child:
                  Column(mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'images/common/camera.svg', height: dp(32),
                        color: Colors.white,),
                      Padding(padding: EdgeInsets.only(top: dp(4))),
                      Text('摄像头拍摄', style: TextStyle(color: Colors.white),),
                    ],)),
                ],),)),
                Padding(padding: EdgeInsets.only(top: dp(8))),
                InkWell(onTap: () async {

                  imagePicker.getVideo(
                      source: ImageSource.gallery).then((value){
                   if(value!=null){
                     videoFileName=value.path;
                     selectedVideo();
                   }
                  });
                }, child:
                Container(padding: EdgeInsets.fromLTRB(dp(32), dp(32), dp(32),
                    dp(32)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .backgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('images/common/upload.svg', color: Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          .color, height: dp(32),),
                      Padding(padding: EdgeInsets.only(right: dp(8))),
                      Text('上传视频', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),)
                    ],),)),
                Expanded(child:
                Container(child: Text(
                  '收益说明：免费视频，每个播放预计收益0.5元。收费视频，单次点播预计收益为视频单价的15%。收益率仅供参考，实际收益以个人中心视频播放数据为准。视频标题和单价信息可在下一步进行设置。',
                  style: TextStyle(height: 1.4, fontSize: 12, color: Theme
                      .of(context)
                      .textTheme
                      .subtitle2
                      .color),),
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(top: dp(32), bottom: dp(32)),)),
              ],)),


            ]),))));
  }


  @override
  void dispose() {
    super.dispose();
  }
}