
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'header.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc.dart';
import '../../service.dart';
import '../../res/colours.dart';
import '../../widget/RoundUnderlineTabIndicator.dart';
import '../../base.dart';
import '../../models.dart';
import '../../common/events.dart';
import '../../tt_index/tt_longvideo/hotlist.dart';
import 'list.dart';
class LongVideoPage extends StatefulWidget {
  LongVideoPage({Key key}) : super(key: key);

  @override
  _LongVideoPageState createState() => _LongVideoPageState();
}
class _LongVideoPageState extends State<LongVideoPage>
    with SingleTickerProviderStateMixin,TTBase {

  TabController _tabController;
  List<LongVideoCategory> categoryList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    categoryList = (BlocObj.longVideoIndex.state['category'] as List<LongVideoCategory>);
    _tabController = new TabController(
        length: categoryList.length,
        vsync: this,initialIndex: 1);

    _tabController.addListener(() {
      if (_tabController.index == _tabController.animation.value) {
        Application.eventBus.fire(StopPlayLongVideoEvent());
      }
    });
  }
@override
void didUpdateWidget(covariant LongVideoPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

      TTService.setAppBarLight();


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


          return BlocBuilder<LongVideoIndexBloc, Map>(
        builder: (context, indexState) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Material(child:Scaffold(body:
          categoryList.length == 0? Container(
              alignment: Alignment.center, child:
          Lottie.asset("asset/loading.json", height: dp(32))) :
          Column(children: [
            Container(
              child: Column(children: [
                Header(),
           Container(color: Theme.of(context).backgroundColor,child:
 Container(  alignment: Alignment.center, decoration: BoxDecoration(
               color: Theme.of(context).backgroundColor,
                  border:Border(bottom:BorderSide(width: 1,color: Theme.of(context).dividerTheme.color) )),padding:EdgeInsets.only(left: dp(8),right: dp(16)),child:
              SizedBox(height:dp(40),child:
              TabBar(
                controller: _tabController,
                indicator: RoundUnderlineTabIndicator(
                  wantWidth: 16,
                  borderSide: const BorderSide(width: 2.0, color: Colours
                      .app_main),
                ),
                isScrollable: true,
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,

                ),
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color,
                labelColor: Colours.app_main,
                indicatorPadding: EdgeInsets.only(bottom: dp(4)),
                indicatorColor: Colours.app_main,
                indicatorWeight: 2,
                labelPadding: EdgeInsets.only(left: dp(8),right: dp(8)),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: categoryList.map((e) => Tab(text: e.name)).toList(),
              ))))

            ],),),
            Expanded(
                child: TabBarView(
                controller: _tabController,
                children: categoryList.asMap()
                      .map((index, item) =>
                      MapEntry(index, Container(

                        child:
                            item.id==-3?LongVideoHotListPage():
                        VideoListPage(
                          longVideoCategory: item, tabPageIndex: index,),
                      )))
                      .values
                      .toList()
            ))
          ],)
          )));
        });
  }
}
