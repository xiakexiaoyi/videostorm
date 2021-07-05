
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_verification_box/verification_box.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../base.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../models.dart';
import '../../res/colours.dart';
import '../../service.dart';
import '../../bloc.dart';
import '../../common/local_storage.dart';



class VerifyCodePage extends StatefulWidget {
  final arguments;
  VerifyCodePage({Key key, this.arguments}) : super(key: key);

  @override
  _VerifyCodePageState createState() => _VerifyCodePageState(arguments);
}

class _VerifyCodePageState extends State<VerifyCodePage> with TTBase {
  final _routeProp;
int _countdownTime=60;
  Timer _timer;
  String _code='';
bool _logining=false;

  _VerifyCodePageState(this._routeProp);


  String contryCode = '+86';



  @override
  void initState() {
    super.initState();
    startCountdown();


  }
  setTimer (timer) {
    if (_countdownTime < 1) {
      print("定时器取消了");
      _timer.cancel();
      _timer=null;
    } else {
      setState(() {
        _countdownTime -= 1;
      });
    }
    print(_countdownTime);
  }
  @override
  void dispose() {
    _countdownTime=0;
    _timer.cancel();
    _timer=null;
    super.dispose();
  }


  startCountdown() {
    print("我竟来了");
    //倒计时时间
    _countdownTime = 60;
    print({
      _countdownTime:_countdownTime,
      _timer:_timer == null
    });
    print(_timer);
    if (_timer == null) {
    print("开启定时器");
    _timer = Timer.periodic(Duration(seconds: 1), setTimer);
    //原因是_timer被赋值了，所以在清除定时器后我手动赋值null
  }

  }

  void login() {
    if (_logining) {
      return;
    }
    _logining = true;
    _loginCallBack(Function func) async {
      var res = await TTService.login(
          _routeProp['phone'], '', _code);
      super.setState(() {
        _code='';
      });

      if (res['code'] != 1) {
        Fluttertoast.showToast(msg: '登录失败' + (res['error'] != null
            ? '，' + res['error'].toString()
            : ''));
      } else {
        print(res);
        User user = User.fromJson(res['data']['user']);
        user.token = res['data']['token'];
        print(user.toJson().toString());
        LocalStorage.save('user', json.encode(user.toJson()).toString());

        final userBloc = BlocProvider.of<UserBloc>(context);
        userBloc.add(UpdateUser(user));
        userBloc.add(UpdateUserLoginState(true));

        CrpytAvatarCacheManager().removeFile(
            TTBase.appConfig.res_server + 'data/avatar/' +
                TTService.generate_MD5(user.id.toString()) + '.dat');

       await Future.delayed(Duration(seconds: 2), (){
         Fluttertoast.showToast(msg: '登录成功');
          func();
          Navigator.of(context).pop({'isLogin': true,'user':user});
        });

      }


      func();
      _logining = false;
    }
    TTDialog.showLoading(
      context, title: '登录中...', dismissDialog: _loginCallBack,);
  }

  void getVerifyCode() {
    _loginCallBack(Function func) async {
      var res = await TTService.getVerifyCode(
          _routeProp['phone']);
      if (res['code'] != 1) {
        Fluttertoast.showToast(msg: '获取验证码失败' + (res['error'] != null
            ? '，' + res['error'].toString()
            : ''), toastLength: Toast.LENGTH_LONG);
      } else {
        startCountdown();
        Fluttertoast.showToast(msg: '已向您的手机发送了一个验证码');
      }
      func();
    }
    TTDialog.showLoading(
      context, title: '验证码获取中...', dismissDialog: _loginCallBack,);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: TTBase.dessignWidth)
      ..init(context);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Theme
              .of(context)
              .scaffoldBackgroundColor,
          leadingWidth: dp(40),

          leading: InkWell(onTap: () {
            Navigator.of(context).pop();
          },
              child: Padding(padding: EdgeInsets.only(left: dp(16)),
                  child: SizedBox.expand(child: SvgPicture.asset(
                    'images/common/goback.svg', height: dp(24), color: Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      .color,)))),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(dp(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('输入验证码完成登录', style: TextStyle(fontSize: 24)),
                Padding(padding: EdgeInsets.only(top: dp(16)),),

                Text('未注册的手机号验证通过后将自动注册', style: TextStyle(color: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .color)),
                Padding(padding: EdgeInsets.only(top: dp(32))),

                Center(child:
                VerificationBox(
                  onSubmitted: (value)
                  {

                    _code=value.toString();
                    login();
                  },
                  type: VerificationBoxItemType.underline,
                  showCursor: true,
                  cursorWidth: 2,
                  borderWidth: 0.6,
                  textStyle: TextStyle(fontSize: 20),
                  count: 4,
                  cursorColor: Colours.app_main,
                  cursorIndent: 10,
                  cursorEndIndent: 10,
                )

                ),


                Padding(padding: EdgeInsets.only(top: dp(32))),
                Row(children: [
                  Expanded(child: ElevatedButton(
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(128,40)),
                          backgroundColor: MaterialStateProperty.resolveWith<
                              Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colours.app_main
                                      .withOpacity(0.5);
                                else
                                if (states.contains(MaterialState.disabled))
                                  return Colours.app_main
                                      .withOpacity(0.5);
                                return null; // Use the component's default./ Use the component's default.
                              })),
                      onPressed: (_countdownTime==0)
                          ? () => getVerifyCode()
                          : null, child: Text('重新发送验证码'+(_countdownTime==0?'':'('+_countdownTime.toString()+')'))))
                ],),
                Padding(padding: EdgeInsets.only(top: dp(16))),
                Center(child: InkWell(onTap: () {
                  Navigator.pop(context);
                }, child: Text('返回上一步'))),

              ],),),
        ));
  }
}
