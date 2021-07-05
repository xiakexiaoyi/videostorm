import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../common/crpyt_avatar_cache_manager.dart';
import '../../../service.dart';
import '../../../common/events.dart';
import '../../../res/colours.dart';
import '../../../bloc.dart';
import '../../../models.dart';
import '../../../base.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();

}
class _ProfilePageState extends State<ProfilePage> with TTBase {

  final imagePicker = ImagePicker();
  File imageFile;
  String avatarUrl=TTBase.appConfig.res_server+'data/avatar/'+TTService.generate_MD5((BlocObj.user.state['user'] as User).id.toString())+ '.dat?'+DateTime.now().microsecondsSinceEpoch.toString();
  @override
  void initState() {
    super.initState();
  }
  Future<void> uploadAvatar(File croppedFile) async {
    _uploadCallBack(Function func) async {
      var res =await TTService.updateAvatar(croppedFile);
      if (res['code'] != 1) {
        Fluttertoast.showToast(msg: '上传失败' +( res['error'] != null
            ? '，' + res['error'].toString()
            : ''));
      } else {
        print(res);
        Fluttertoast.showToast(msg: '头像设置成功');
        CrpytAvatarCacheManager().removeFile(TTBase.appConfig.res_server+'data/avatar/'+TTService.generate_MD5((BlocObj.user.state['user'] as User).id.toString())+ '.dat');
Application.eventBus.fire(UpdateAvatarEvent());
        super.setState(() {
          avatarUrl=TTBase.appConfig.res_server+'data/avatar/'+TTService.generate_MD5((BlocObj.user.state['user'] as User).id.toString())+ '.dat?'+DateTime.now().microsecondsSinceEpoch.toString();
        });
      }

      func();
    }
    TTDialog.showLoading(
      context, title: '头像上传中...', dismissDialog: _uploadCallBack,);

  }
  Future<Null> cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      cropStyle: CropStyle.circle,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 99,
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,

        ]
            : [
          CropAspectRatioPreset.square,

        ],
        androidUiSettings: AndroidUiSettings(
          statusBarColor: Colors.white,
            showCropGrid: false,
            toolbarTitle: '',
            hideBottomControls: true,
            toolbarWidgetColor: Colors.white,
            toolbarColor: Colours.dark_bg_color,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(

          title: '裁剪头像',
        ));
    if (croppedFile != null) {

     print('裁剪完毕');
      uploadAvatar(croppedFile);
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, Map>(
        builder: (context, indexState) {
          return Scaffold(
              appBar: new AppBar(
                centerTitle: true,
                title: new Text('编辑资料', style: TextStyle(color: Theme
                    .of(context)
                    .textTheme
                    .bodyText1
                    .color)),
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
              body:
              Container(
                color: Theme
                    .of(context)
                    .backgroundColor,
                child: ListView(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(width: 0.5,
                                color: Colours.text_gray.withOpacity(0.2)),
                                top: BorderSide(width: 0.5,
                                    color: Colours.text_gray.withOpacity(0.2))),
                            color: Theme
                                .of(context)
                                .backgroundColor
                        ),
                        margin: EdgeInsets.only(top: dp(8)),
                        padding: EdgeInsets.only(left: dp(16), right: dp(0)),
                        child:
                        Column(children: [
                          Padding(padding: EdgeInsets.only(top:dp(32)),),
                          InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                          decoration:BoxDecoration(
                                            color: Theme.of(context).backgroundColor,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                                          ),

                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                title: Text('拍照',
                                                    textAlign: TextAlign
                                                        .center),
                                                onTap: () {
                                                  imagePicker.getImage(source: ImageSource.camera).then((value) {
                                                    imageFile=File(value.path);
                                                    Navigator.pop(context);
                                                    cropImage();
//
//                                                  Navigator.pushNamed(context, '/avatar_edit',arguments:{'_avatarFile':value.path});
                                                  });

                                                },
                                              ),
                                              Divider(),
                                              ListTile(
                                                title: Text('从手机相册选择',
                                                    textAlign: TextAlign
                                                        .center),
                                                onTap: () {
                                                  imagePicker.getImage(source: ImageSource.gallery).then((value) {
                                                    Navigator.pop(context);
                                                    imageFile=File(value.path);
                                                    cropImage();
//                                                    Navigator.pop(context);
//                                                    Navigator.pushNamed(context, '/avatar_edit',arguments:{'_avatarFile':value.path});

                                                  });
                                                },
                                              ),
                                              Divider(),
                                              Container(padding: EdgeInsets.only(top:dp(8)),color: Theme.of(context).scaffoldBackgroundColor),
                                              ListTile(
                                                title: Text('取消',
                                                    textAlign: TextAlign
                                                        .center),
                                                onTap: () {
                                                  Navigator.pop(context, '取消');
                                                },
                                              ),
                                            ],
                                          ));
                                    });


                              },
                              child:
                              Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(48),
                                  child:
                                  Container(
                                      height: dp(80),
                                      width: dp(80),
                                      color: Theme.of(context).textTheme.subtitle2.color,
                                      child:CachedNetworkImage(fadeInDuration: Duration(milliseconds: 200),fit: BoxFit.cover,
                                          imageUrl:(avatarUrl),
                                          cacheManager: CrpytAvatarCacheManager(),
                                          errorWidget:(BuildContext context, Object exception, StackTrace ){ return SvgPicture.asset('images/common/defaultavatar.svg',height: dp(80),width: dp(80),color: Theme.of(context).backgroundColor,);})),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child:
                                  Container(
                                      height: dp(80),
                                      width: dp(80),
                                      color: Colors.black54,
                                      child: Container(padding: EdgeInsets.all(dp(24)),height: dp(24),child:  SvgPicture.asset('images/common/camera.svg',height: dp(16),width: dp(16),color: Colors.white,))),
                                ),
                              ],)),

                          Padding(padding: EdgeInsets.only(top:dp(16)),),
                          Center(child: Text('点击更换头像'),),
                          Padding(padding: EdgeInsets.only(top:dp(32)),),
                          InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, '/profile/username');
                            },
                            child:
                          Row(
                            children: [
                              Text('用户名'),
                              Expanded(child: Container(
                                  height: dp(48),
                                  alignment: Alignment.centerRight,
                                  child: Text((BlocObj.user.state['user'] as User).username))),
                              Padding(padding: EdgeInsets.only(right: dp(8))),
                              SvgPicture.asset(
                                'images/common/goto.svg', height: dp(16),
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2
                                    .color,),
                              Padding(padding: EdgeInsets.only(right: dp(8)))
                            ],
                          ),),
                          Divider(),


                        ],)
                    ),

                  ],
                ),
              ));
        });
  }
}