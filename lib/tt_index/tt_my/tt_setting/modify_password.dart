import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../bloc.dart';
import '../../../service.dart';
import '../../../res/colours.dart';
import '../../../base.dart';
class ModifyPasswordPage extends StatefulWidget {
  @override
  _ModifyPasswordPageState createState() => _ModifyPasswordPageState();

}
class _ModifyPasswordPageState extends State<ModifyPasswordPage> with TTBase {

  FocusNode oldPasswordFocusNode;
  FocusNode newPasswordFocusNode;
  FocusNode rnewPasswordFocusNode;
  TextEditingController oldPasswordTextFieldController;
  TextEditingController newPasswordTextFieldController;
  TextEditingController rnewPasswordTextFieldController;

  @override
  void initState() {
    super.initState();

    oldPasswordTextFieldController = new TextEditingController();
    newPasswordTextFieldController= new TextEditingController();
    rnewPasswordTextFieldController= new TextEditingController();
    oldPasswordFocusNode=new FocusNode();
    newPasswordFocusNode=new FocusNode();
    rnewPasswordFocusNode=new FocusNode();

  }

  void modifyPassword() async {
    _yesCallBack(){
      Navigator.pop(context);
    }
    _callBack(Function func) async {
      var res = await TTService.modifyPassword(
          oldPasswordTextFieldController.text,newPasswordTextFieldController.text,rnewPasswordTextFieldController.text);
      if (res['code'] != 1) {
        func();

        Fluttertoast.showToast(msg: '密码修改失败' + (res['error'] != null
            ? '，' + res['error'].toString()
            : ''), toastLength: Toast.LENGTH_LONG);
      } else {
        func();
       TTDialog.alert(context, text: '密码修改成功，您可以使用新密码登录了',yesCallBack: _yesCallBack);
      }
    }
    TTDialog.showLoading(
      context, title: '正在提交...', dismissDialog: _callBack,);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, Map>(
        builder: (context, indexState) {
          return Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              appBar: new AppBar(
                centerTitle: true,
                title: new Text('修改密码', style: TextStyle(color: Theme
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
                padding: EdgeInsets.all(dp(16)),
                child: Column(children: [
                  Container(

                decoration: BoxDecoration( color: Theme.of(context).backgroundColor,
                border: Border(
                  left: BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color,),
                  right: BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color,),
                  top: BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color,),
              ),
          ), child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: TextField(
                        keyboardType: TextInputType.visiblePassword,
                        focusNode: oldPasswordFocusNode,
                        obscureText: true,
                        onChanged: (value){setState(() {

                        });},
                        controller: oldPasswordTextFieldController,
                        decoration: InputDecoration(
                          hintText: "请输入旧密码",
                          border: InputBorder.none,
                        ),
                      ),
                    ),),
                  Container(

                    decoration: BoxDecoration( color: Theme.of(context).backgroundColor,
                      border: Border(
                        left: BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color,),
                        right: BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color,),
                        top: BorderSide(width: 0.5,color:Theme.of(context).dividerTheme.color,),
                      ),
                    ), child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      focusNode: newPasswordFocusNode,
                      onChanged: (value){setState(() {

                      });},
                      controller: newPasswordTextFieldController,
                      decoration: InputDecoration(
                        hintText: "请输入新密码",
                        border: InputBorder.none,
                      ),
                    ),
                  ),),
                  Container(

                    decoration: BoxDecoration( color: Theme.of(context).backgroundColor,
                      border: Border.all(width: 0.5,color:Theme.of(context).dividerTheme.color,),
                    ), child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      focusNode: rnewPasswordFocusNode,
                      obscureText: true,
                      onChanged: (value){setState(() {

                      });},
                      controller: rnewPasswordTextFieldController,
                      decoration: InputDecoration(
                        hintText: "请再次输入新密码",
                        border: InputBorder.none,
                      ),
                    ),
                  ),),
                  Padding(padding: EdgeInsets.only(top:dp(16))),
                  Row(children: [
                    Expanded(child: ElevatedButton(
                      child: Text('确定修改'),
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
                        onPressed: (oldPasswordTextFieldController.text.isNotEmpty&&newPasswordTextFieldController.text.isNotEmpty&&rnewPasswordTextFieldController.text.isNotEmpty)?(){
                          oldPasswordFocusNode.unfocus();
                          newPasswordFocusNode.unfocus();
                          rnewPasswordFocusNode.unfocus();
modifyPassword();
                        }:null))
                  ],),
                  Padding(padding: EdgeInsets.only(top:dp(16))),
                  Text('初始密码在您第一次使用验证码登录时已发送到您的手机上',style: TextStyle(fontSize: 12,color: Theme.of(context).textTheme.subtitle2.color),)
                ],),

              ));
        });
  }
}