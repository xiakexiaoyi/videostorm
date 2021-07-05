import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../bloc.dart';
import '../../common/events.dart';
import '../../res/colours.dart';
import '../../service.dart';
import '../../base.dart';



class LoginPage extends StatefulWidget {
  final arguments;
  LoginPage({Key key, this.arguments}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(arguments);
}

class _LoginPageState extends State<LoginPage> with TTBase {
  final _routeProp;
  String _country = '中国大陆';
  String _phoneNumber = '86';
  int type = 2; // 0:注册, 1:手机号码+密码登录, 2:手机号码+验证码登录, 3:昵称登录

  _LoginPageState(this._routeProp) {

  }


  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    if(BlocObj.user.state['isLogin']){
      Navigator.pop(context,{'isLogin':BlocObj.user.state['isLogin'],'user':BlocObj.user.state['user']});
    }
    super.initState();
    Application.eventBus.fire(StopPlayLongVideoEvent());
  }

  @override
  void dispose() {

    super.dispose();
  }


void getVerifyCode() {
  _loginCallBack(Function func) async {
    var res = await TTService.getVerifyCode(
        _phoneController.text);
    if (res['code'] != 1) {
      func();
      Fluttertoast.showToast(msg: '获取验证码失败' +( res['error'] != null
          ? '，' + res['error'].toString()
          : ''),toastLength: Toast.LENGTH_LONG);
    } else {
      func();
      Navigator.pushNamed(context, '/verifycode', arguments: {
        'phone': _phoneController.text
      }).then((value){
        print('验证码登录成功'+value.toString());

      });
    }


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
//          brightness: Brightness.light,
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
                Text('手机登录', style: TextStyle(fontSize: 24)),
                Padding(padding: EdgeInsets.only(top: dp(16)),),

                Text('未注册的手机号验证通过后将自动注册', style: TextStyle(color: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .color)),
                Padding(padding: EdgeInsets.only(top: dp(32))),
                Row(children: [
                  Expanded(child: TextField(
                    autofocus: true,
cursorColor: Colours.app_main,
                    onChanged:(value){super.setState(() {});},
                    keyboardType: TextInputType.phone,
controller: _phoneController,
                    textAlignVertical: TextAlignVertical.center,
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
                          onChanged: print,
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
                  Expanded(child:
                  ElevatedButton(
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
                      onPressed:_phoneController.text.isNotEmpty?()=>getVerifyCode():null, child: Text('获取验证码并登录')))
                ],),
                Padding(padding: EdgeInsets.only(top: dp(16))),
                Center(child:InkWell(onTap: (){
                  Navigator.pushNamed(context, '/login_password', arguments: {
                    'type': 'login'
                  }).then((value) => {

                  });
                },child: Text('使用手机号和密码登陆'))),

              ],),),
        ));

  }
}
