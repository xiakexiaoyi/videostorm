import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../service.dart';
import '../../../common/local_storage.dart';
import '../../../res/colours.dart';
import '../../../bloc.dart';
import '../../../models.dart';
import '../../../base.dart';
class UserNamePage extends StatefulWidget {
  @override
  _UserNamePageState createState() => _UserNamePageState();

}
class _UserNamePageState extends State<UserNamePage> with TTBase {
bool _hasdeleteIcon;
FocusNode focusNode;
TextEditingController usernameTextFieldController;
 @override
  void initState() {

    super.initState();

   usernameTextFieldController=new TextEditingController();
    focusNode=new FocusNode();
    usernameTextFieldController.text=(BlocObj.user.state['user'] as User).username;
    if( usernameTextFieldController.text.length>0){
      _hasdeleteIcon=true;
    }
  }
void userModify() async{

  _callBack(Function func) async {
    var res = await TTService.userModify(
        usernameTextFieldController.text);
    if (res['code'] != 1) {
      func();
      Fluttertoast.showToast(msg: '用户名修改失败' +( res['error'] != null
          ? '，' + res['error'].toString()
          : ''),toastLength: Toast.LENGTH_LONG);
    } else {
      func();
      final userBloc = BlocProvider.of<UserBloc>(context);
      User user = (BlocObj.user.state['user'] as User);
      user.username = usernameTextFieldController.text;
      userBloc.add(UpdateUser(user));
      LocalStorage.save('user',json.encode(user.toJson()).toString());
      Navigator.pop(context);
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
            backgroundColor: Theme.of(context).backgroundColor,
              appBar: new AppBar(
                centerTitle: true,
                actions: [
                  InkWell(
                      onTap:(){
                  if(usernameTextFieldController.text.isNotEmpty){
                    focusNode.unfocus();
                    userModify();
                  }
          },
                      child:
                Container(
                    alignment: Alignment.center,
                padding: EdgeInsets.only(right: dp(16),left: dp(16)),
                child:
                  Text('提交', style: TextStyle(color: Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      .color,fontSize: 16))))
                ],
                title: new Text('用户名', style: TextStyle(color: Theme
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
                padding: EdgeInsets.only(left: dp(16),right: dp(16),top: dp(16)),
                child:Column(children: [
                 Row(children: [
               Expanded(child:  TextField(
                 autofocus: false,
                   onChanged: (str) {
                     setState(() {
                       if (str.isEmpty) {
                         _hasdeleteIcon = false;
                       } else {
                         _hasdeleteIcon = true;
                       }
                     });
                   },
                   controller:usernameTextFieldController,
                   cursorColor: Colours.app_main,
                   focusNode: focusNode,
                decoration: InputDecoration(
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
                  suffixIconConstraints: BoxConstraints(),
                  suffixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: 8, end:0),
                      child:
                      Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.end,children: [

                      _hasdeleteIcon
                      ?
                  InkWell(
                      onTap: (){
                        setState(() {

                          usernameTextFieldController.text = '';
                          _hasdeleteIcon = false;
                        });

                      },
                      child:
                      Container(
                          height: dp(20),
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .textTheme
                                .subtitle2
                                .color
                                .withOpacity(0.5),
                            shape: BoxShape.circle,
                          ), child: Container(
                        padding: EdgeInsets.all(dp(4)), child:
                      SvgPicture.asset(
                        'images/common/close.svg', height: 8,
                        color: Colors.white,),)))

                  : Padding(padding: EdgeInsets.only(right: 0)),
                        Container(
                            padding: EdgeInsets.only(left: dp(8),right: dp(8)),
                            child: 
                        SizedBox(
                          width: 0.5,
                          height: dp(24),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2
                                    .color),
                          ),
                        )),
                        InkWell(onTap: (){

                          usernameTextFieldController.text=TTBase.randomUserNameList[new Random().nextInt(TTBase.randomUserNameList.length)];
                          setState(() {
                            _hasdeleteIcon = true;
                          });


                        },child: Container(child: Text('随机生成'),),)
                      ])))




              ))
                 ],)
                ],),

              ));
        });
  }
}