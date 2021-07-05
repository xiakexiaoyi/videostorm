
import 'dart:io';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:date_format/date_format.dart';
import 'package:lottie/lottie.dart';
import './net.dart';
import './base.dart';
import 'dart:convert';
import './common/local_storage.dart';
import 'bloc.dart';
import './tt_dialog/loading.dart';
import 'models.dart';
abstract class TTService {
  //1.可直接播放 0.需要消耗播放次数 -1.不可播放
static int canPlay(int video_id) {
  if (BlocObj.user.state['isLogin'] &&
      (BlocObj.user.state['user'] as User).vip_time > DateTime
          .now()
          .millisecondsSinceEpoch) {
    return 1;
  } else {
    DateTime play_lastdate=DateTime.fromMillisecondsSinceEpoch(TTBase.localData.play_lastdate);
    DateTime now=DateTime.now();
    print(formatDate(play_lastdate,[yyyy,'-',mm,'-',dd])+'  '+now.toString());
    if (TTBase.localData.played_videoids.contains(video_id)) {
      return 1;
    }
    else if (formatDate(now,[yyyy,'-',mm,'-',dd])!=formatDate(play_lastdate,[yyyy,'-',mm,'-',dd])) {
      TTBase.localData.played_free = 0;
      TTBase.localData.play_lastdate = DateTime
          .now()
          .millisecondsSinceEpoch;
      return 0;
    } else {
      if (!BlocObj.user.state['isLogin'] &&
          TTBase.localData.played_free < TTBase.appConfig.play_count_free) {
        return 0;
      } else if(BlocObj.user.state['isLogin']&&TTBase.localData.played_free < TTBase.appConfig.play_count_free+TTBase.appConfig.play_count_free_login){
        return 0;
      }
      else {
        return -1;
      }
    }
  }
}
  static Future<void> loadLocalData() async {
    String jsonString = await LocalStorage.get('local_data');
    if(jsonString==null){TTBase.localData=new LocalData();}
    else{
      TTBase.localData=LocalData.fromJson(json.decode(jsonString));
    }
  }
  static Future<void> saveLocalData() async {
     await LocalStorage.save('local_data',json.encode(TTBase.localData).toString());

  }
  static void refreshUserInfo(context) async {
    if (BlocObj.user.state['isLogin']) {
      var user = BlocObj.user.state['user'] as User;
      var res = await TTService.userInfo(user.token);
      if (res['code'] == 1) {
        user = User.fromJson(res['data']['user']);
        print('本地用户身份信息校验成功');
        LocalStorage.save('user',json.encode(user.toJson()).toString());
        final userBloc = BlocProvider.of<UserBloc>(context);
        userBloc.add(UpdateUser(user));
        userBloc.add(UpdateUserLoginState(true));

      }else if(res['code']!=-66){
        //身份失效
        BlocObj.user.state['isLogin']=false;
        final userBloc = BlocProvider.of<UserBloc>(context);
        userBloc.add(UpdateUser(null));
        userBloc.add(UpdateUserLoginState(false));
        LocalStorage.remove('user');
      }


    }
  }
  static bool checkLogin(context) {
    if (!BlocObj.user.state['isLogin']) {
      Navigator.pushNamed(context, '/login');
      return false;
    } else {
      return true;
    }
  }
static void setAppBarLight(){

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
}
static void setAppBarDark(){

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
}
  static Future<Map> getVideoList(context, category) async {

    var data={'category':category};
    var res = await netHelper.httpPost(data, API.videoList);
    return res;
  }
  static Future<Map> getUserVideoList(user_id,long,offset) async {

    var data={'user_id':user_id,'long':long,'offset':offset};
    var res = await netHelper.httpPost(data, API.video_user);
    return res;
  }
  static Future<Map> historyList(context, last_id) async {

    var data={'last_id':last_id};
    var res = await netHelper.httpPost(data, API.history_list);
    return res;
  }
  static Future<Map>favoriteList(context, last_id) async {

    var data={'last_id':last_id};
    var res = await netHelper.httpPost(data, API.favorite_list);
    return res;
  }
  static Future<Map> getHotTags() async {
    var res = await netHelper.httpPost({'t': DateTime.now().microsecondsSinceEpoch.toString()}, API.tag_hot);
    return res;
  }
  static Future<Map> getTagList() async {
    var res = await netHelper.httpPost({'t': DateTime.now().microsecondsSinceEpoch.toString()}, API.tag_list);
    return res;
  }
  static Future<Map> getFollowTopUsers() async {
    var res = await netHelper.httpPost({'t': DateTime.now().microsecondsSinceEpoch.toString()}, API.follow_top);
    return res;
  }
  static Future<Map> getHotVideos( category) async {

    var data={'category':category};
    var res = await netHelper.httpPost(data, API.video_top);
    return res;
  }

  static Future<Map> getRecommendVideos(context, category) async {

    var data={'category':category,'recommend':true};
    var res = await netHelper.httpPost(data, API.videoList);
    return res;
  }
  static Future<Map> getFollowVideos(long,offset) async {

    var data={'long':long,'offset':offset};
    var res = await netHelper.httpPost(data, API.videoFollow);
    return res;
  }
  static Future<Map> videoSearch(keyword,sort,long,offset) async {

    var data={'keyword':keyword,'sort':sort,'long':long,'offset':offset};
    var res = await netHelper.httpPost(data, API.video_search);
    return res;
  }
static Future<Map> getVerifyCode(String phoneNumber) async {
  var res = await netHelper.httpPost({'phone': phoneNumber}, API.verify_code);
  return res;
}
static Future<Map> addFavorite(String hash) async {
  var res = await netHelper.httpPost({'hash': hash}, API.favorite_add);
  return res;
}
static Future<Map> removeFavorite(String hash,bool all,List<String>hashs) async {
  Map postdata = {'hash': hash};
  if (all) {
    postdata = {'all': true};
  };
  if (hashs.length > 0) {
    postdata = {'list':hashs};
  }

  var res = await netHelper.httpPost(
     postdata, API.favorite_remove);
  return res;
}
  static Future<Map> userModify(String username) async {
    var res = await netHelper.httpPost({'username': username}, API.user_modify);
    return res;
  }
  static Future<Map> modifyPassword(String old_password,String password,String password2) async {
    var res = await netHelper.httpPost({'old_password': old_password,'password':password,'password2':password2}, API.modify_password);
    return res;
  }
    static Future<Map> userInfo(String token) async {
      var res = await netHelper.httpPost({'t': DateTime.now().millisecondsSinceEpoch.toString()}, API.user_info,token: token);
      return res;
    }
static Future<Map> addLike(String hash) async {
  var res = await netHelper.httpPost({'hash': hash}, API.like_add);
  return res;
}
  static Future<Map> addFollow(int user_id) async {
    var res = await netHelper.httpPost({'user_id': user_id}, API.follow_add);
    return res;
  }
  static Future<Map> userFollow(order,offset,user_id) async {

    var data={'order':order,'offset':offset,};
    if(user_id.toString().isNotEmpty){
      data={'order':order,'offset':offset,'user_id':user_id};
    }
    var res = await netHelper.httpPost(data, API.user_follow);
    return res;
  }
static Future<Map> userFans(offset,user_id) async {

  var data={'offset':offset,};
  if(!user_id.toString().isNotEmpty){
    data={'offset':offset,'user_id':user_id};
  }
  var res = await netHelper.httpPost(data, API.user_fans);
  return res;
}
  static Future<Map>removeFollow(int user_id) async {
    var res = await netHelper.httpPost({'user_id': user_id}, API.follow_remove);
    return res;
  }
static Future<Map> removeLike(String hash) async {
    var res = await netHelper.httpPost({'hash': hash}, API.like_remove);
    return res;
  }
  static Future<Map> addHistory(String hash,double position) async {
    var res = await netHelper.httpPost({'hash': hash,'position':position}, API.history_add);
    return res;
  }
  static Future<Map> removeHistory(String hash,bool all,List<String>hashs) async {
    Map postdata = {'hash': hash};
    if (all) {
      postdata = {'all': true};
    };
    if (hashs.length > 0) {
      postdata = {'list':hashs};
    }

    var res = await netHelper.httpPost(
        postdata, API.history_remove);
    return res;
  }
static Future<Map> login(String phoneNumber,String password,String verifyCode) async {
  var res = await netHelper.httpPost({'phone': phoneNumber,'password':password,'verify_code':verifyCode}, API.login);
  return res;
}
static Future<Map> updateAvatar(File file) async {
  var filedata = await file.readAsBytes();

  var res = await netHelper.httpPost(
      {'avatar_base64': base64.encode(filedata.toList()),}, API.update_avatar);
  return res;
}

static Future<Map>uploadVideo(String filePath,{Function progressCallback,Function cancel}) async {
  var res=await netHelper.uploadFileHttp(API.video_upload, filePath,progressCallback:progressCallback );
  return res;

}

static Future<String>getCacheSzie() async {
  double _cacheSize = 0;

  final cacheDir = await getTemporaryDirectory();
  print(cacheDir);
  if (cacheDir.existsSync()) {
    cacheDir.listSync(recursive: true, followLinks: true)
        .forEach((element) {
      if (element is File) {
        _cacheSize = _cacheSize + element.lengthSync();
      }
    });
    return formateFileSize(_cacheSize);
  }
}
static Future clearCache() async {
  try{
    final cacheDir = await getTemporaryDirectory();
    if(cacheDir.existsSync()){
      cacheDir.deleteSync(recursive: true);
    }
  }catch(e){
    print('缓存文件删除失败：' + e.toString());
  }

}
static Future<Map> getconfig() async {
  var res = await netHelper.httpPost({'t': DateTime.now().microsecondsSinceEpoch.toString()}, API.config);
  return res;
}
  static Future<List<LongVideoCategory>> getCategoryList(context) async {

    var res = await netHelper.httpPost({'t':DateTime.now().microsecondsSinceEpoch.toString()}, API.categoryList);
    print(res);
    List<LongVideoCategory>categoryList=new List();
    categoryList.add(new LongVideoCategory(0,'关注',999));
    categoryList.add(new LongVideoCategory(-2,'推荐',999));
    categoryList.add(new LongVideoCategory(-3,'热门',999));

    if (res['code']!=null&&res['code'] == 1) {
      print('成功加载长视频分类：' + (res['data']['list'] as List).length.toString());
      (res['data']['list'] as List).forEach((element) {
        LongVideoCategory longVideoCategory = new LongVideoCategory(element['id'], element['name'], element['show_index']);

        categoryList.add(longVideoCategory);
      });
    }else{
      categoryList.clear();
    }
    return categoryList;
  }

 static String formateDuration(int seconds) {
    var d = Duration(seconds:seconds);
    List<String> parts = d.toString().split(':');
    if(int.parse(parts[0])==0){ return '${parts[1]}:${  parts[2].substring(0,parts[2].indexOf('.'))}';}
    else{ return '${parts[0]}:${parts[1]}:${  parts[2].substring(0,parts[2].indexOf('.'))}';}

  }

// 格式化数值
  static String formatNum(int number) {
    if (number > 10000) {
      var str = TTService._formatNum(number / 10000, 1);
      if (str.split('.')[1] == '0') {
        str = str.split('.')[0];
      }
      return str + '万';
    }
    return number.toString();
  }
  static String _formatNum(double number, int postion) {
    if((number.toString().length - number.toString().lastIndexOf(".") - 1) < postion) {
      // 小数点后有几位小数
      return ( number.toStringAsFixed(postion).substring(0, number.toString().lastIndexOf(".")+postion + 1).toString());
    } else {
      return ( number.toString().substring(0, number.toString().lastIndexOf(".") + postion + 1).toString());
    }
  }
  static String formateFileSize(double value) {
    if (null == value) {
      return '0.00B';
    }
    List<String> unitArr = List()
      ..add('B')
      ..add('KB')
      ..add('MB')
      ..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }
  // 格式化时间
  static String formatTime(int timeSec) {
    num toSeconds(num date) {
      return date / 1000;
    }

    num toMinutes(num date) {
      return toSeconds(date) / 60;
    }

    num toHours(num date) {
      return toMinutes(date) / 60;
    }

    num toDays(num date) {
      return toHours(date) / 24;
    }

    var date = DateTime.fromMillisecondsSinceEpoch(timeSec * 1000);
    num delta = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    if (delta < 1 * 60000) {
      num seconds = toSeconds(delta);
      return (seconds <= 0 ? 1 : seconds).toInt().toString() + '秒前' ;
    }
    if (delta < 45 * 60000) {
      num minutes = toMinutes(delta);
      return (minutes <= 0 ? 1 : minutes).toInt().toString() + '分钟前' ;
    }
    if (delta < 24 * 3600000) {
      num hours = toHours(delta);
      return (hours <= 0 ? 1 : hours).toInt().toString() + "小时前";
    }
    if (delta < 48 * 3600000) {
      return "昨天";
    }
    if (delta < 30 * 86400000) {
      num days = toDays(delta);
      return (days <= 0 ? 1 : days).toInt().toString() + "天前";
    }
    else {
      return '${date.year.toString()}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
 static String generate_MD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes).toLowerCase();
  }
  // 生成随机串
  static dynamic randomBit(int len, { String type }) {
    String character = type == 'num' ? '0123456789' : 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    String left = '';
    for (var i = 0; i < len; i++) {
      left = left + character[Random().nextInt(character.length)];
    }
    return type == 'num' ? int.parse(left) : left;
  }
}

abstract class TTDialog {
  // 默认弹窗alert
  static void alert(context, {
    @required String text, String title = '', String yes = '确定',String cancel='取消',
    Function yesCallBack
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:title.length>0? Text(title):null,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text,style:TextStyle(height:TTBase().dp(1.6))),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(yes),
              onPressed: () {
                if (yesCallBack != null) yesCallBack();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {});
  }

  static void showCustomDialog(context, {
    @required String text, String title = '', String yes = '确定',String cancel='取消',
    Function okCallBack,Function cancelCallBack
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:title.length>0? Text(title):null,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text,style:TextStyle(height:TTBase().dp(1.6))),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(cancel),
              onPressed: () {
                if (cancelCallBack != null) cancelCallBack();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(yes),
              onPressed: () {
                if (okCallBack != null) okCallBack();
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    ).then((val) {});
  }
  static void showLoading(context, {
    String title = '正在加载...', Function dismissDialog
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            dismissDialog: dismissDialog,
            text: title,
          );
        }
    );
  }

}

// 禁用点击水波纹
class NoSplashFactory extends InteractiveInkFeatureFactory {
  @override
  InteractiveInkFeature create({
    MaterialInkController controller,
    RenderBox referenceBox,
    Offset position,
    Color color,
    TextDirection textDirection,
    bool containedInkWell = false,
    rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    onRemoved
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
  }) : super(
    controller: controller,
    referenceBox: referenceBox,
  );

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}

// 去除安卓滚动视图水波纹
class TTBehaviorNull extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildViewportChrome(context,child,axisDirection);
    }
  }
}

// 下拉刷新头部、底部组件
class TTRefreshHeader extends StatelessWidget with TTBase {
  @override
  Widget build(BuildContext context) {
    final refreshing = Lottie.asset(
        'asset/loading.json',
        height: dp(64)
    );

    return CustomHeader(
        refreshStyle: RefreshStyle.Follow,
        builder: (BuildContext context,RefreshStatus status) {
          bool swimming = (status == RefreshStatus.refreshing || status == RefreshStatus.completed);
          return Container(
              height: dp(50),
              child: Stack(
                  alignment: AlignmentDirectional.center,
                 children: [
//                    swimming ? SizedBox() : Image.asset(
//                      'images/fun_home_pull_down.png',
//                      height: dp(50),
//                    ),
                    Offstage(
                      offstage: !swimming,
                      child: refreshing,
                    ),
                  ]
              )
          );
        }
    );
  }
}

class TTRefreshFooter extends StatelessWidget with TTBase {
  final bgColor;

  TTRefreshFooter({this.bgColor});

  @override
  Widget build(BuildContext context) {
    final height = dp(50);

    return CustomFooter(
      height: height,
      builder: (BuildContext context, LoadStatus mode) {
        final textStyle = TextStyle(
          fontSize: dp(12),
        );
        Widget body;
        Widget loading = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
                'asset/loading.json',
                height: dp(32)
            ),
            Padding(padding: EdgeInsets.only(left: dp(8))),
            Text(
              '用力加载中...',
              style: textStyle,
            ),
          ],
        );
        if (mode == LoadStatus.idle) {
          body = loading;
        }
        else if (mode == LoadStatus.loading) {
          body = loading;
        }
        else if (mode == LoadStatus.failed) {
          body = Text(
            '网络出错啦 😭',
            style: textStyle,
          );
        }
        else if (mode == LoadStatus.canLoading) {
          body = loading;
        }
        else {
          body = Text(
            '没有更多了',
            style: textStyle,
          );
        }
        return Container(
          height: height,
          child: Center(child: body),
        );
      },
    );
  }
}
