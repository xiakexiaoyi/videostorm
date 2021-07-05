import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../common/events.dart';
import '../../service.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/crpyt_image_cache_manager.dart';
import '../../models.dart';
import '../../res/colours.dart';
import '../../../bloc.dart';
import '../../../base.dart';
class VideoUploadPage extends StatefulWidget with TTBase {
  final arguments;
  VideoUploadPage({Key key, this.arguments}) : super(key: key);
  @override
  _VideoUploadPageState createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> with SingleTickerProviderStateMixin,TTBase {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  String videoFileName;
  bool uploading=false;
int video_upload_count=0;
int video_file_size=100;
  @override
  void initState() {
    super.initState();
    videoFileName=(widget.arguments as Map<String, Object>)['videoFileName'];
    videoPlayerController = VideoPlayerController.file(new File(videoFileName))
      ..initialize().then((_) {
        chewieController = ChewieController(
            allowedScreenSleep: false,
            allowPlaybackSpeedChanging: false,
            showControlsOnInitialize: false,
            videoPlayerController: videoPlayerController,
            autoPlay: false,
            showOptions: false,
            looping: false,
            allowFullScreen: true,
            deviceOrientationsAfterFullScreen:[
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,]
        );
        setState(() {});
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        appBar: new AppBar(
          centerTitle: true,
          actions: [
          ],
          title: Text(
            '发布视频', style: TextStyle(color: Theme
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
        body: Column(children: [

          Container(
              margin: EdgeInsets.only(left: dp(16), right: dp(16)),

              decoration: new BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(4)),),
              alignment: Alignment.center,
              height: (TTBase.screenWidth - 32) * 9 / 16,
              child:
              Column(
                children: <Widget>[

                  Expanded(
                    child:
                    Center(
                      child:
                          Stack(children:[
                      chewieController != null &&
                          videoPlayerController.value.isInitialized
                          ? ClipRRect(
                          borderRadius: BorderRadius.circular(4), //弧度
                          child: Chewie(
                            controller: chewieController,
                          ))
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Colours.app_main,),
                        ],
                      ),
                        !uploading?Padding(padding: EdgeInsets.zero,):Container( decoration: new BoxDecoration(
    color: Colors.black.withOpacity(0.8),
    borderRadius: BorderRadius.all(Radius.circular(4)),),child:Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [
                            CircularProgressIndicator(color: Colours.app_main,value: video_upload_count/video_file_size,backgroundColor: Colors.grey.withOpacity(0.4),),
                            Padding(padding: EdgeInsets.only(top: dp(8))),
                            Text('视频上传中：'+((video_upload_count/video_file_size)*100).round().toString()+'%',style: TextStyle(color: Colors.white),)
                          ],),))
                          ])
                    ),
                  ),


                ],)


              ),
          Container(
            decoration: new BoxDecoration(
              color: Theme
                  .of(context)
                  .backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(4)),),
            margin: EdgeInsets.only(left: dp(16), right: dp(16), top: dp(8)),
            child:
            TextField(maxLines: 4,
                decoration: InputDecoration(
                  hintText: '输入标题（必填）',
                  contentPadding: EdgeInsets.only(left: 12, top: 12),
                  border: InputBorder.none,
                )),


          ),
          Expanded(child: Container(padding: EdgeInsets.only(
              left: dp(16), right: dp(16), bottom: dp(8)),
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(child: ElevatedButton(
                  child: Text(uploading?'取消发布':'发布'),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(128, 40)),
                      backgroundColor: MaterialStateProperty.resolveWith<
                          Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Colours.app_main
                                  .withOpacity(0.5);
                            else if (states.contains(MaterialState.disabled))
                              return Colours.app_main
                                  .withOpacity(0.5);
                            return uploading?Colours.app_main
                                .withOpacity(0.5):Colours.app_main;
                          })),
                  onPressed:uploading?(){
                    Application.eventBus.fire(StopUploadFileEvent(videoFileName));
                  }: () {
                    setState(() {
                      uploading = true;
                    });
                    TTService.uploadVideo(videoFileName, progressCallback: (
                        upload_count, file_size) {
                      setState(() {
                        video_upload_count=upload_count;
                        video_file_size=file_size;
                      });

//                      print('count:' + upload_count.toString() + ' total:' +
//                          file_size.toString());
                    }).then((value) {
                      setState(() {
                        uploading = false;
                      });
                      if (value['code'] == 1) {
                        print(
                            '远程文件名：' + TTBase.appConfig.res_server + '/temp/' +
                                value['data']['md5'] + '.dat');
                      }
                    });
                  }))
            ],),)),

        ],)

    );
  }



}