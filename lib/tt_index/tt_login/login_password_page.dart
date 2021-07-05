import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/local_storage.dart';
import '../../res/colours.dart';
import '../../service.dart';
import '../../base.dart';
import '../../bloc.dart';
import '../../models.dart';



class LoginPasswordPage extends StatefulWidget {
  final arguments;
  LoginPasswordPage({Key key, this.arguments}) : super(key: key);

  @override
  _LoginPasswordPageState createState() => _LoginPasswordPageState(arguments);
}

class _LoginPasswordPageState extends State<LoginPasswordPage> with TTBase {
  final _routeProp;



  _LoginPasswordPageState(this._routeProp);


    String contryCode='+86';
  TextEditingController _phoneController =new TextEditingController();

  TextEditingController _passwordController =new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

void login()
{
  _loginCallBack(Function func) async {
    var res = await TTService.login(
        _phoneController.text, _passwordController.text, '');
    if (res['code'] != 1) {
      Fluttertoast.showToast(msg: '登录失败' +( res['error'] != null
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
  }
  TTDialog.showLoading(
    context, title: '登录中...', dismissDialog: _loginCallBack,);
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
                Text('密码登录', style: TextStyle(fontSize: 24)),
                Padding(padding: EdgeInsets.only(top: dp(16)),),

                Text('尚未注册的手机请使用验证码登录并设置密码', style: TextStyle(color: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .color)),
                Padding(padding: EdgeInsets.only(top: dp(32))),
                Row(children: [
                  Expanded(child: TextField(
                    cursorColor: Colours.app_main,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    controller: _phoneController,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged:(value){super.setState(() {});},
                    decoration: InputDecoration(
                      hintText: '手机号',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme
                            .of(context)
                            .textTheme
                            .subtitle2
                            .color,width: 0.1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .color,width: 0.1),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme
                            .of(context)
                            .textTheme
                            .subtitle2
                            .color,width: 0.1),
                      ),
                      prefixIcon:
                      SizedBox(
                        width: dp(120),
                        child:
                        CountryCodePicker(
                          showDropDownButton: true,
                          textStyle: TextStyle(color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color, fontSize: 18),
                          alignLeft: true,
                          padding: EdgeInsets.only(left: 0),
                          onChanged:(value){contryCode=value.toString();},
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: 'CN',
                          showFlag: false,
                          dialogBackgroundColor: Theme
                              .of(context)
                              .backgroundColor,
                          boxDecoration: BoxDecoration(color: Theme
                              .of(context)
                              .backgroundColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(dp(8)))),
                          dialogTextStyle: TextStyle(color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color),
                          comparator: (a, b) => b.name.compareTo(a.name),
                          //Get the country information relevant to the initial selection
                          onInit: (code) =>
                              print(
                                  "on init ${code.name} ${code.dialCode} ${code
                                      .name}"),
                        ),
                      ),
                    ),)),
                ],),
                Padding(padding: EdgeInsets.only(top: dp(16))),
                Row(children: [
                  Expanded(child: TextField(
                    controller: _passwordController,
                      cursorColor: Colours.app_main,
                      keyboardType:TextInputType.visiblePassword ,
                      obscureText: true,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged:(value){super.setState(() {});},
                      decoration: InputDecoration(
                        hintText: '密码',
                        contentPadding: EdgeInsets.only(left: dp(8)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2
                              .color,width: 0.1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,width: 0.1),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2
                              .color,width: 0.1),
                        ),
                      )))]),
                Padding(padding: EdgeInsets.only(top: dp(32))),
                Row(children: [
                  Expanded(child: ElevatedButton(
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(128,40)),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Colours.app_main
                                  .withOpacity(0.5);
                            else if (states.contains(MaterialState.disabled))
                              return  Colours.app_main
                                  .withOpacity(0.5);
                            return null; // Use the component's default./ Use the component's default.
                          })),
                      onPressed:(_phoneController.text.isNotEmpty&&_passwordController.text.isNotEmpty)?()=>login():null, child: Text('登录')))
                ],),
                Padding(padding: EdgeInsets.only(top: dp(16))),
                Center(child:InkWell(onTap: (){
                  Navigator.pop(context);
                },child: Text('使用验证码登录'))),

              ],),),
        ));

  }
}
