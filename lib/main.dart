import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:videostorm/tt_index/tt_upload/index.dart';
import 'package:videostorm/tt_index/tt_upload/upload_page.dart';
import 'package:videostorm/tt_index/tt_user/fans_page.dart';
import 'package:videostorm/tt_index/tt_user/follow_page.dart';
import './base.dart';
import './tt_index/tt_login/login_password_page.dart';
import './tt_index/tt_login/verifycode_page.dart';
import './tt_index/tt_my/tt_setting/modify_password.dart';
import './tt_index/tt_shortvideo/player_page.dart';
import './tt_index/tt_user/index.dart';
import './tt_splash/ad.dart';
import 'tt_index/tt_my/favorite_page.dart';
import './tt_index/tt_my/playrecord_page.dart';
import './tt_index/tt_my/tt_setting/index.dart';
import './tt_index/tt_my/tt_setting/username_page.dart';
import './tt_index/tt_search/index.dart';
import './tt_splash/index.dart';
import './tt_index/index.dart';
import './provider/theme.dart';
import 'bloc.dart';
import './tt_index/tt_shortvideo/index.dart';
import './tt_index/tt_my/index.dart';
import './tt_index/tt_game/index.dart';
import './tt_index/tt_bbs/index.dart';
import './tt_index/tt_live/index.dart';
import 'tt_index/tt_login/index.dart';
import 'tt_index/tt_longvideo/player.dart';
import 'tt_index/tt_my/tt_setting/profile_page.dart';
class TTApp extends StatelessWidget {
  // 路由路径匹配
  Route<dynamic> _getRoute(RouteSettings settings) {
    Map<String, WidgetBuilder> routes = {
      '/ad':(BuildContext context) => AdPage(),
      '/': (BuildContext context) => SplashPage(),
      '/index': (BuildContext context) => IndexPage(),
      '/shortvideo':(BuildContext context) => ShortVideoIndexPage(),
      '/login': (BuildContext context) => LoginPage(arguments: settings.arguments),
      '/search': (BuildContext context) => SearchIndexPage(arguments: settings.arguments),
      '/user': (BuildContext context) => UserIndexPage(arguments: settings.arguments),
      '/user/follow': (BuildContext context) => UserFollowPage(arguments: settings.arguments),
      '/user/fans': (BuildContext context) => UserFansPage(arguments: settings.arguments),
      '/my':(BuildContext context) => MyPage(),
      '/game':(BuildContext context) => GamePage(),
      '/live':(BuildContext context) => LivePage(),
      '/bbs':(BuildContext context) => BBsPage(),
      '/setting':(BuildContext context) => SettingPage(),
      '/playrecord':(BuildContext context) => PlayRecordPage(),
      '/favorite':(BuildContext context) => FavoritePage(),
      '/upload/selectvideo':(BuildContext context) => VideoUploadIndexPage(),


    };
    var widget = routes[settings.name];

    if (widget != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: widget,
      );
    }else{
      switch (settings.name) {
        case '/login_password':
          return PageTransition(
            child: LoginPasswordPage(arguments: settings.arguments),
            type: PageTransitionType.rightToLeftWithFade,
            settings: settings,
          );
          break;
        case '/verifycode':
          return PageTransition(
            child: VerifyCodePage(arguments: settings.arguments),
            type: PageTransitionType.rightToLeftWithFade,
            settings: settings,
          );
          break;
        case '/shortvideo_player':
          return PageTransition(
            child: ShortVideoPlayerPage(arguments: settings.arguments),
            type: PageTransitionType.rightToLeftWithFade,
            settings: settings,
          );
          break;
        case '/profile':
        return PageTransition(
          child: ProfilePage(),
          type: PageTransitionType.rightToLeftWithFade,
          settings: settings,
        );
        break;
        case '/profile/username':
        return PageTransition(
          child: UserNamePage(),
          type: PageTransitionType.rightToLeftWithFade,
          settings: settings,
        );
        break;
        case '/modify_password':
          return PageTransition(
            child: ModifyPasswordPage(),
            type: PageTransitionType.rightToLeftWithFade,
            settings: settings,
          );
          break;
        case '/longvideo_player':
          return PageTransition(
            child: LongVideoPlayPage(arguments: settings.arguments),
            type: PageTransitionType.rightToLeftWithFade,
            settings: settings,
          );
          break;
        case '/upload/upload':
          return PageTransition(
            child: VideoUploadPage(arguments: settings.arguments),
            type: PageTransitionType.rightToLeftWithFade,
            settings: settings,
          );
          break;
        default:
          return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<IndexBloc>(
            create: (context) => BlocObj.index,
          ),
          BlocProvider<LongVideoIndexBloc>(
            create: (context) => BlocObj.longVideoIndex,
          ),
          BlocProvider<UserBloc>(
            create: (context) => BlocObj.user,
          ),
        ],

        child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: ThemeProvider()),
            ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeProvider.themeData(),
                darkTheme: themeProvider.themeData(isDarkMode: true),
                themeMode: themeProvider.getThemeMode(),
                title: TTBase.appName,

                onGenerateRoute: _getRoute,
              );
            })
        ));

  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  runApp(TTApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

}
