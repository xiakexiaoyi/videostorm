import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_util/sp_util.dart';
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../../common/local_storage.dart';
import '../../net.dart';
import '../../service.dart';
import '../../models.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../provider/theme.dart';
import 'dart:convert';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TTBase {
  String loadingState = '线路选择中...';
  SharedPreferences prefs;
  bool loadingSuccess = false;

  @override
  void initState() {
    loadingState = '初始化...';
    super.initState();

    SpUtil.getInstance();
    _loadServer().then((value) {
      if (TTBase.serverUrl.length == 0) {
        super.setState(() {
          loadingState = '暂无可用线路，请重启APP再次尝试！';
        });
        super.setState(() {
          TTDialog.alert(context, text: '暂无可用线路，请重启APP再次尝试！');
        });
      }else{
        print('使用服务器：'+TTBase.serverUrl);
      }
    });
  }

  Future<void> initData() async {
    setState(() {
      loadingState = '数据预加载中...';
      loadingSuccess = false;
    });
    await _loadUUID();
    await _loadConfig();
    try {
      await _loadLocalData();
    } catch (error) {
      print('本地信息加载失败：' + error.toString());
    }
    await _loadHotTags();
     _loadFollowTopUsers();

    for(int i=0;i<3;i++) {
      await _loadLongVideoCategory();
      if ((BlocObj.longVideoIndex.state['category'] as List).length == 0) {
        //栏目加载失败
      } else {
        break;
      }
    }
    if ((BlocObj.longVideoIndex.state['category'] as List).length == 0) {
      //未能成功加载栏目
      List<LongVideoCategory>categoryList=new List();
      categoryList.add(new LongVideoCategory(0,'关注',999));
      categoryList.add(new LongVideoCategory(-2,'推荐',999));
      categoryList.add(new LongVideoCategory(-3,'热门',999));
      final longVideoIndexBloc = BlocProvider.of<LongVideoIndexBloc>(context);
      longVideoIndexBloc.add(UpdateCategory(categoryList));
    }
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    TTBase.playerAndCoverHeight = screenWidth * 9 / 16;
    TTBase.screenHgight = MediaQuery
        .of(context)
        .size
        .height;
    TTBase.screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    setState(() {
      loadingState = '初始化完毕';
      loadingSuccess = true;
      //设置主题
      Provider.of<ThemeProvider>(context, listen: false).syncTheme();
      //进入广告
      Navigator.of(context).pushReplacementNamed('/ad');
    });
  }

  Future<void> _loadFollowTopUsers() async {
    var res = await TTService.getFollowTopUsers();
    TTBase.followTopUsers = [];
    if (res['code'] == 1) {
      (res['data']['user'] as List).forEach((item) {
        if (TTBase.followTopUsers.length >= 50) {
          return;
        }
        TTBase.followTopUsers.add(User.fromJson(item));
      });
    }
  }

  Future<bool> _loadServer() async {
    super.setState(() {
      loadingState = '线路选择中...';
    });
    for (int i = 0; i < TTBase.serverList.length; i++) {

      try {
        var res = await httpClientGlobal.get(TTBase.serverList[i].toString());
        if (res.data.toString().contains('code')) {
          print('成功选择服务器：' + TTBase.serverList[i]);

          TTBase.serverUrl =TTBase.serverList[i];
          initHttpClient();
          initData();
          return true;
        } else {
          print('服务器检测返回：' + res.data.toString());
        }
      } catch (e) {
        print('服务器：' + TTBase.serverList[i] + ' 不可用：' + e.toString());
      }
    }
    return false;
  }

  Future<void> _loadLocalData() async {
    TTService.loadLocalData();
    var jsonString = await LocalStorage.get('user');
    if (jsonString != null) {
      print(jsonString);
      User user = User.fromJson(json.decode(jsonString));
      print('获取到本地用户信息：' + user.token);
      var res = await TTService.userInfo(user.token);
      if (res['code'] == 1) {
        //token认证成功
        user = User.fromJson(res['data']['user']);
        print('本地用户身份信息校验成功');
        LocalStorage.save('user', json.encode(user.toJson()).toString());
      } else if (res['code'] != -66) {
        //身份失效，非网络问题
        BlocObj.user.state['isLogin'] = false;
        final userBloc = BlocProvider.of<UserBloc>(context);
        userBloc.add(UpdateUser(null));
        userBloc.add(UpdateUserLoginState(false));
        LocalStorage.remove('user');
      }


      final userBloc = BlocProvider.of<UserBloc>(context);
      userBloc.add(UpdateUser(user));
      userBloc.add(UpdateUserLoginState(true));

      CrpytAvatarCacheManager().removeFile(
          TTBase.appConfig.res_server + 'data/avatar/' +
              TTService.generate_MD5(user.id.toString()) + '.dat');
    } else {
      print('未能获取到本地的用户登录信息');
    }

    //获取搜索历史
    TTBase.searchHistoryList = [];
    jsonString = await LocalStorage.get('search_history');
    if (jsonString != null) {
      (json.decode(jsonString) as List).forEach((item) {
        SearchHistory searchHistory = SearchHistory.fromJson(item);
        TTBase.searchHistoryList.add(searchHistory);
      });
    }
  }

  Future<void> _loadUUID() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        TTBase.UUID =
            TTService.generate_MD5(build.androidId); //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        TTBase.UUID =
            TTService.generate_MD5(data.identifierForVendor); //UUID for iOS
      }
      print('获取到设备ID：' + TTBase.UUID);
    } catch (e) {
      print('无法获取设备信息：' + e.toString());
    }
  }

  Future<void> _loadHotTags() async {
    var res = await TTService.getHotTags();
    TTBase.hotTags = [];
    if (res['code'] == 1) {
      (res['data']['tags'] as List).forEach((item) {
        Tag tag = Tag.fromJson(item);
        TTBase.hotTags.add(tag);
      });
    }
  }

  // 获取导航列表
  Future<void> _loadLongVideoCategory() async {
    final longVideoIndexBloc = BlocProvider.of<LongVideoIndexBloc>(context);
    var list = await TTService.getCategoryList(context);
    longVideoIndexBloc.add(UpdateCategory(list));
  }

  Future<void> _loadConfig() async {
    var res = await TTService.getconfig();
    if (res['code'] == 1) {
      TTBase.appConfig.res_server = res['data']['res_server'];
      print('资源服务器地址：' + TTBase.appConfig.res_server);
    }
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: TTBase.dessignWidth)
      ..init(context);

    return Scaffold(

      body: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
                child:
                Image.asset(
                  'images/splash/bg.png',
                  fit: BoxFit.cover,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                )),
            Positioned(
                bottom: dp(24),
                child:
                Column(children: [
                  Image.asset('images/splash/logo.png', width: dp(48),),
                  // SvgPicture.asset('images/logo.svg',height: dp(48),),
                  Padding(padding: EdgeInsets.only(top: dp(8))),
                  Text(TTBase.appName)
                ],)
            )
          ],
        ),
      ),
    );
  }
}
