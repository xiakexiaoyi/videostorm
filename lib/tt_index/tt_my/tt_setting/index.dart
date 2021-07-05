import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../bloc.dart';
import '../../../service.dart';
import '../../../common/local_storage.dart';
import '../../../res/colours.dart';
import '../../../base.dart';
import '../../../provider/theme.dart';
class SettingPage extends StatefulWidget with TTBase {
  @override
  _SettingPageState createState() => _SettingPageState();

}
class _SettingPageState extends State<SettingPage> with TTBase {
  String cacheSize='计算中...';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TTService.getCacheSzie().then((value)  {
      super.setState(() {
        cacheSize=value;
      });
    });
  }
  void loginOut(BuildContext context) async{
    void _okCallBack(){
      final userBloc = BlocProvider.of<UserBloc>(context);
      userBloc.add(UpdateUser(null));
      userBloc.add(UpdateUserLoginState(false));
      LocalStorage.remove('user');
      Navigator.pop(context);
    }
    TTDialog.showCustomDialog(context, text: '退出当前账号后将不能收藏视频，发布和无限观看精彩内容哦',title: '退出确认',yes:'确认退出',okCallBack: _okCallBack);
  }
  @override
  Widget build(BuildContext context) {

    return BlocBuilder<UserBloc, Map>(
        builder: (context, indexState) {
          return Scaffold(
              appBar: new AppBar(
                centerTitle: true,
                title: new Text('设置', style: TextStyle(color: Theme
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

                          BlocObj.user.state['isLogin']? InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, '/profile');
                            },
                            child: Row(
                              children: [
                                Text('编辑资料'),
                                Expanded(child: Container(
                                  height: dp(48),
                                  alignment: Alignment.centerRight,
                                )),
                                SvgPicture.asset(
                                  'images/common/goto.svg', height: dp(16),
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .subtitle2
                                      .color,),
                                Padding(padding: EdgeInsets.only(right: dp(8)))
                              ],
                            ),):Padding(padding: EdgeInsets.zero),
                          BlocObj.user.state['isLogin']?Divider():Padding(padding: EdgeInsets.zero),
                          BlocObj.user.state['isLogin']? InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, '/modify_password');
                            },
                            child: Row(
                              children: [
                                Text('修改密码'),
                                Expanded(child: Container(
                                  height: dp(48),
                                  alignment: Alignment.centerRight,
                                )),
                                SvgPicture.asset(
                                  'images/common/goto.svg', height: dp(16),
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .subtitle2
                                      .color,),
                                Padding(padding: EdgeInsets.only(right: dp(8)))
                              ],
                            ),):Padding(padding: EdgeInsets.zero),
                          BlocObj.user.state['isLogin']?Divider():Padding(padding: EdgeInsets.zero),
                          InkWell(onTap: (){
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
                                            title: Text('浅色模式',
                                                textAlign: TextAlign
                                                    .center),
                                            onTap: () {
                                              Navigator.pop(context, '取消');
                                              TTBase.localData.theme='Light';
                                              TTService.saveLocalData();
                                              Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.light);
                                            },
                                          ),
                                          Divider(),
                                          ListTile(
                                            title: Text('深色模式',
                                                textAlign: TextAlign
                                                    .center),
                                            onTap: () {
                                              Navigator.pop(context, '取消');
                                              TTBase.localData.theme='Dark';
                                              TTService.saveLocalData();
                                              Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.dark);
                                            },
                                          ),
                                          Divider(),
                                          ListTile(
                                            title: Text('跟随系统',
                                                textAlign: TextAlign
                                                    .center),
                                            onTap: () {
                                              Navigator.pop(context, '取消');
                                              TTBase.localData.theme='System';
                                              TTService.saveLocalData();
                                              Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.system);
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
                          },child:
                          Row(
                            children: [
                              Text('主题模式'),
                              Expanded(child: Container(
                                  height: dp(48),
                                  alignment: Alignment.centerRight,
                                  child: Text(TTBase.localData.theme=='System'?'跟随系统':(TTBase.localData.theme=='Dark'?'深色模式':'浅色模式')))),
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
                          )),
//                          Divider(),
//                          Row(
//                            children: [
//                              Text('无痕浏览'),
//                              Expanded(child: Container(
//                                  alignment: Alignment.centerRight,
//                                  child: Switch(
//                                    value: true, onChanged: (value) {},)))
//                            ],
//                          ),
                          Divider(),
                        InkWell(onTap: (){
                          okCallBack(){
                            setState(() {
                              cacheSize='清理中...';
                            });
                              TTService.clearCache().then((value) {
                                if(this.mounted){
                                  setState(() {
                                    cacheSize='0.00B';
                                  });
                                }
                              });

                          }
                          TTDialog.showCustomDialog(context, text: '确定要删除所有缓存？不影响视频播放和历史记录。',okCallBack: okCallBack);

                        },child:  Row(
                            children: [
                              Text('清理缓存'),
                              Expanded(child: Container(
                                  height: dp(48),
                                  alignment: Alignment.centerRight,
                                  child: Text(cacheSize))),
                              Padding(padding: EdgeInsets.only(right: dp(8))),

                              Padding(padding: EdgeInsets.only(right: dp(8)))
                            ],
                          ))
                        ],)
                    ),
                    BlocObj.user.state['isLogin']? Container(
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
                        child:
                        Column(children: [
                          Row(
                            children: [
                              Expanded(child:
                              InkWell(
                                  onTap: () {
                                    loginOut(context);
                                  },
                                  child: Container(
                                      height: dp(48),
                                      alignment: Alignment.center,
                                      child: Text('退出登录', style: TextStyle(
                                          color: Colours.app_main))))),

                            ],
                          ),

                        ],)
                    ):Padding(padding: EdgeInsets.zero,)

                  ],
                ),
              ));
        });
  }
}