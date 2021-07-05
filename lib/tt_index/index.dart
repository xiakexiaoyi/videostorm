import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../base.dart';
import '../../common/events.dart';
import '../../res/colours.dart';
import '../../tt_index/tt_my/index.dart';
import '../../tt_index/tt_shortvideo/index.dart';
import '../tt_index/tt_game/index.dart';
import '../tt_index/tt_longvideo/index.dart';
class IndexPage extends StatefulWidget {
  final arguments;
  IndexPage({Key key, this.arguments}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TTBase {
  final _bottomNavList = ['长视频','短视频','游戏中心','我的']; // 底部导航
  DateTime _lastCloseApp; //上次点击返回按钮时间
  int _currentIndex = 0;  // 底部导航当前页面
  ScrollController _scrollController = ScrollController();  // 首页整体滚动控制器
  PageController _pageController = PageController();

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  // 点击悬浮标回到顶部
  void _indexPageScrollTop() {
    _scrollController.animateTo(.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }
@override
void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    ScreenUtil.instance = ScreenUtil(width: TTBase.dessignWidth)..init(context);

    return WillPopScope(
      onWillPop: () async {
        if (_lastCloseApp == null || DateTime.now().difference(_lastCloseApp) > Duration(seconds: 1)) {
          _lastCloseApp = DateTime.now();
          Fluttertoast.showToast(msg: '再按一次退出');
          return false;
        }
        return true;
      },
      child: Scaffold(
        // 底部导航栏
        bottomNavigationBar:Container(child: BottomNavigationBar(

           backgroundColor: _currentIndex==1?Colours.dark_bg_color:Theme.of(context).backgroundColor,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedFontSize:dp(12),
            unselectedFontSize: dp(12),
            onTap: (index) {

              if (mounted)
                setState(() {
                  _currentIndex = index;
                });
              Application.eventBus.fire(StopPlayLongVideoEvent());
              _pageController.jumpToPage(index);

            },
            items: [
              BottomNavigationBarItem(
                  label: _bottomNavList[0],
                  icon: _currentIndex == 0
                      ? _bottomIcon('images/nav/tab_ic_home_sel.png')
                      : _bottomIcon('images/nav/tab_ic_home.png')),
              BottomNavigationBarItem(
                  label: _bottomNavList[1],
                  icon: _currentIndex == 1
                      ? _bottomIcon('images/nav/tab_ic_iv_sel.png')
                      : _bottomIcon('images/nav/tab_ic_iv.png')),
              BottomNavigationBarItem(
                  label: _bottomNavList[2],
                  icon: _currentIndex == 2
                      ? _bottomIcon('images/nav/tab_ic_game_sel.png')
                      : _bottomIcon('images/nav/tab_ic_game.png')),
//              BottomNavigationBarItem(
//                  label: _bottomNavList[3],
//                  icon: _currentIndex == 3
//                      ? _bottomIcon('images/nav/tab_ic_live_sel.png')
//                      : _bottomIcon('images/nav/tab_ic_live.png')),
//              BottomNavigationBarItem(
//                  label: _bottomNavList[4],
//                  icon: _currentIndex == 4
//                      ? _bottomIcon('images/nav/tab_ic_commu_sel.png')
//                      : _bottomIcon('images/nav/tab_ic_commu.png')),
              BottomNavigationBarItem(
                  label: _bottomNavList[3],
                  icon: _currentIndex == 3
                      ? _bottomIcon('images/nav/tab_ic_my_sel.png')
                      : _bottomIcon('images/nav/tab_ic_my.png')),
            ]
        )),
        body: _currentPage(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  // 底部导航对应的页面
  Widget _currentPage() {
    var _pages = [
      LongVideoPage(),
      ShortVideoIndexPage(),
      GamePage(),
      MyPage(),
    ];

    return PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemCount: _pages.length,
        itemBuilder: (context,index)=>_pages[index]
    );
  }

  Widget _bottomIcon(path) {
    return Padding(
        padding: EdgeInsets.only(bottom: dp(4)),
        child: Image.asset(
          path,
          width: dp(25),
          height: dp(25),
          repeat:ImageRepeat.noRepeat,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        )
    );
  }

}
