import 'dart:ui';

import '../base.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../res/colours.dart';
import '../service.dart';

class ThemeProvider extends ChangeNotifier {

  static const Map<ThemeMode, String> themes = {
    ThemeMode.dark: 'Dark', ThemeMode.light : 'Light', ThemeMode.system : 'System'
  };

  void syncTheme() {
    String theme = TTBase.localData.theme;
    print('加载主题：'+theme);
    if (theme.isNotEmpty && theme != themes[ThemeMode.system]) {
      notifyListeners();
    }
  }

  void setTheme(ThemeMode themeMode) {
   TTBase.localData.theme= themes[themeMode];
   TTService.saveLocalData();
    notifyListeners();
  }

  ThemeMode getThemeMode(){
    String theme = TTBase.localData.theme;
    switch(theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  themeData({bool isDarkMode: false}) {
    return ThemeData(
      backgroundColor:isDarkMode ? Colours.dark_bg_color : Colours.bg_color ,

        errorColor: isDarkMode ? Colours.dark_red : Colours.red,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        accentColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // Tab指示器颜色
        indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // 页面背景色
        scaffoldBackgroundColor: isDarkMode ? Colours.dark_bg_gray :Colours.bg_gray,
        // 主要用于Material背景色
        canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
        // 文字选择色（输入框复制粘贴菜单）
        textSelectionColor: Colours.app_main.withAlpha(70),
        textSelectionHandleColor: Colours.app_main,
        textTheme: TextTheme(
          // TextField输入文字颜色
          subhead: isDarkMode ?
          TextStyle(
              fontSize: 14,
              color: Colors.white,
              textBaseline: TextBaseline.alphabetic
          ): TextStyle(
              fontSize: 16,
              color: Colours.text,
              textBaseline: TextBaseline.alphabetic
          ),
          // Text文字样式
          body1: isDarkMode ? TextStyle(
              fontSize: 14,
              color: Colours.dark_text,
              textBaseline: TextBaseline.alphabetic
          ) : TextStyle(
              fontSize: 14,
              color: Colours.text,
              textBaseline: TextBaseline.alphabetic
          ),
          subtitle: isDarkMode ? TextStyle(
              fontSize: 12,
              color: Colours.dark_text_gray,
              fontWeight: FontWeight.normal
          ) : TextStyle(
              fontSize: 28,
              color: Colours.text_gray,
              fontWeight: FontWeight.normal
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: isDarkMode ? TextStyle(
              fontSize: 16,
              color: Colours.dark_text_gray
          ) : TextStyle(
            fontSize: 16,
            color: Colours.dark_text_gray,
          ),
        ),
        bottomNavigationBarTheme:BottomNavigationBarThemeData (
            unselectedItemColor: isDarkMode ? Colours.text_gray : Colours.text_gray,
          selectedItemColor: Colours.app_main,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: isDarkMode ? Colours.dark_bg_color : Colors.white,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        dividerTheme: DividerThemeData(
            color: isDarkMode ? Colours.dark_line : Colours.line,
            space: 0.6,
            thickness: 0.6
        ),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        splashFactory: NoSplashFactory(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:ButtonStyle(
          backgroundColor:MaterialStateProperty.all<Color>( Colours.app_main),
          foregroundColor: MaterialStateProperty.all<Color>( Colors.white)
        ),
      )
    );
  }

}