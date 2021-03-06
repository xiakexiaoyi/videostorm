import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../base.dart';
import '../../res/colours.dart';
import '../../service.dart';
import '../../tt_index/tt_shortvideo/hotlist.dart';
import '../../tt_index/tt_shortvideo/list.dart';
import '../../widget/RoundUnderlineTabIndicator.dart';
class ShortVideoIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ShortVideoIndexPageState();
  }
}
class _ShortVideoIndexPageState extends State<ShortVideoIndexPage> with TTBase,TickerProviderStateMixin{

  TabController _tabController;
  PageController  _pageController;
  double _screenHeight;
  double _screenWidth;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this,initialIndex:2);
  _pageController = PageController(initialPage: 2,keepPage: true);
//  WidgetsBinding.instance.addPostFrameCallback((_bottomBarLayout) {

//  });
}
  @override
  Widget build(BuildContext context) {

    _screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    _screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(child:Scaffold(body: _body(),)));
  }

  _body(){
    return Container(
      width: _screenWidth,
      height:  _screenHeight,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
              child: _tabContent()),
          Positioned(
              top: MediaQueryData.fromWindow(window).padding.top,
              child: _header()),
        ],
      ),
    );
  }
  _header(){
    return  Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
       crossAxisAlignment: CrossAxisAlignment.center,
      children: [

                    Container(
                      padding: EdgeInsets.only(bottom: dp(4)),
                      alignment: Alignment.center,
            margin: EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: (){
Navigator.pushNamed(context, '/search');
              },
              child: SvgPicture.asset('images/common/search.svg',height: dp(24),color: Colors.white70,),
            ),
          ),

        Container(child:_tabBar(),),

              Container(
                padding: EdgeInsets.only(bottom: dp(4)),
               // padding: EdgeInsets.only(bottom: 0),
            margin: EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: (){
                if (TTService.checkLogin(context)) {
                  Navigator.pushNamed(context, '/upload/selectvideo');
                }
              },
              child:  SvgPicture.asset('images/common/camera.svg',height: dp(24),color: Colors.white70,),
            ),
          ),
      ],)
    );

  }
  _tabBar(){
    return Container(
      alignment: Alignment.center,
     width: dp(160),
      child:
        TabBar(
          tabs: [
            Text('??????'),
            Text('??????'),
            Text('??????'),
          ],
          labelPadding: EdgeInsets.only(bottom: 4),
          indicator: RoundUnderlineTabIndicator(
            wantWidth:16,
            borderSide:const BorderSide(width:2.0, color: Colors.white),
          ),
          //??????tab???????????????
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
          ),
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          //??????tab???????????????
          labelColor: Colors.white,
          //??????tab??????????????????
          unselectedLabelColor: Colors.white70,
          //???????????????tab???????????????CustomUnderlineTabIndicator
          indicatorPadding:EdgeInsets.only(bottom: dp(0)) ,
          //???????????????????????????????????????
          indicatorColor: Colours.app_main,  // ?????????????????????
          indicatorWeight: 2,  // ?????????????????????
          //indicatorPadding
          //indicatorSize  ?????????????????????????????????
          ///??????????????????????????????TabBarIndicatorSize.label???????????????,TabBarIndicatorSize.tab?????????tab??????
          indicatorSize: TabBarIndicatorSize.label,
          controller: _tabController,
          onTap: (index){
            _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.linear);
          },

        ),
    );
  }
  _tabContent() {
    double contentHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: contentHeight,
      ),
      child: NotificationListener(
        child: PageView(
            controller: _pageController,
            children: [
              ShortVideoHotListPage(),
              ShortVideoListPage(true),
             ShortVideoListPage(false)
            ],
            onPageChanged: (index) {
              _tabController.animateTo(index);
            }),
        onNotification: (overscroll){
          if (overscroll is OverscrollNotification && overscroll.overscroll != 0 && overscroll.dragDetails != null) {
            if(overscroll.overscroll > 0){
              //widget._scrollPageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.linear);
            }else {

            }
          }
          return true;
        },
      ),
    );
  }
  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}