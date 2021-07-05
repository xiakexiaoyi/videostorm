import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../common/crpyt_avatar_cache_manager.dart';
import '../../common/events.dart';
import '../../common/local_storage.dart';
import '../../res/colours.dart';
import '../../service.dart';
import '../../tt_index/tt_search/result_page.dart';
import '../../widget/RoundUnderlineTabIndicator.dart';
import '../../base.dart';
import 'result_page.dart';
import '../../models.dart';

class SearchIndexPage extends StatefulWidget {
  final arguments;

  SearchIndexPage({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SearchIndexPageState();
  }
}
class _SearchIndexPageState extends State<SearchIndexPage> with TTBase,TickerProviderStateMixin {

  String hintText = '请输入关键词';
  FocusNode focusNode;
  TextEditingController searchTextFieldController;
  var inputFormatters;
  var onEditingComplete;
  var _hasdeleteIcon = false;
  List<Tag>hotTags;
  List <User>followTopUsers;
  List<Tag>allTags = [];
  List<VideoModel>hotLongVideos;
  List<VideoModel>hotShortVideos;
  bool getRandomTagsRunning = false;
  TabController hotController;
  TabController resultTabControl;
  bool showResultPage=false;
  GlobalKey<SearchResultPageState> childKey_LongVideo = GlobalKey();
  GlobalKey<SearchResultPageState> childKey_ShortVideo = GlobalKey();
  SearchResultPage searchResultPage_LongVideo;
  SearchResultPage searchResultPage_ShortVideo;
  String keyword='';
  String filterSortSelected='default';
  String filterSort='default';
double  _filterPanelOpacity=0;
    var __filterPanelTransform;
    List<SearchHistory>visibleSearchHistorys=[];

  @override
  void initState() {
    focusNode = new FocusNode();
    // TODO: implement initState
    super.initState();
    Application.eventBus.fire(StopPlayLongVideoEvent());
    searchTextFieldController = new TextEditingController();
    resultTabControl = new TabController(length: 2, vsync: this);
    resultTabControl.addListener(() {
      if (_filterPanelOpacity > 0) {
        _onFilterPanel();
      }
    });
    hotController = new TabController(length: 3, vsync: this);
    searchTextFieldController.addListener(() {
      if (searchTextFieldController.text.length > 0) {
        _hasdeleteIcon = true;
      } else {
        _hasdeleteIcon = false;
      }
      setState(() {

      });
    });


    getHotTags();
    getHotVideos();
    getFollowTopUsers();
  }

  getHotTags() async {
    var res = await TTService.getHotTags();
    hotTags = [];
    if (res['code'] == 1) {
      (res['data']['tags'] as List).forEach((item) {
        Tag tag = Tag.fromJson(item);
        hotTags.add(tag);
      });
    }
    setState(() {

    });
  }
getFollowTopUsers()async {
  var res = await TTService.getFollowTopUsers();
  followTopUsers = [];
  if (res['code'] == 1) {
    (res['data']['user'] as List).forEach((item) {

      if (followTopUsers.length >= 50) {
        return;
      } User user = User.fromJson(item);
      followTopUsers.add(user);
    });
  }
}
  getHotVideos() async {
    var res = await TTService.getHotVideos(-2);
    hotLongVideos = [];
    if (res['code'] == 1) {
      (res['data']['list'] as List).forEach((item) {
        VideoModel videoModel = VideoModel.fromJson(item);
        if(hotLongVideos.length>=50){return;}
        videoModel.image= TTBase.appConfig.res_server+videoModel.image;
        hotLongVideos.add(videoModel);
      });
    }
    var res_short = await TTService.getHotVideos(-1);
    hotShortVideos = [];
    if (res_short['code'] == 1) {
      (res_short['data']['list'] as List).forEach((item) {
        VideoModel videoModel = VideoModel.fromJson(item);
        videoModel.image= TTBase.appConfig.res_server+videoModel.image;
        hotShortVideos.add(videoModel);
        if(hotShortVideos.length>=50){return;}
      });
    }


    setState(() {

    });
  }

  getRandomTags() async {
    setState(() {
      getRandomTagsRunning = true;
    });

    if (allTags.length == 0) {
      var res = await TTService.getTagList();

      if (res['code'] == 1) {
        (res['data']['tags'] as List).forEach((item) {
          Tag tag = Tag.fromJson(item);
          allTags.add(tag);
        });
      }
    }
    hotTags.clear();
    if (allTags.length > 0) {
      var tempTags = List<Tag>.generate(
          allTags?.length,
              (int index) {
            return allTags[index];
          }, growable: true);


      while (tempTags.length > 0) {
        int index = new Random().nextInt(tempTags.length);
        hotTags.add(tempTags[index]);
        tempTags.removeAt(index);
      }
      tempTags.clear();
    }
    setState(() {
      getRandomTagsRunning = false;
    });
  }
getSearchResult() async{

}
  void   _onFilterPanel() {
    setState(() {
      _filterPanelOpacity = _filterPanelOpacity == 1.0 ? 0.0 : 1.0;
      __filterPanelTransform = _filterPanelOpacity == 0.0
          ? Matrix4.translationValues(0, -128, 0)
          : Matrix4.translationValues(0, 0, 0);
    });
  }
  void reSearch() async {
    focusNode.unfocus();
    var searchHistory = TTBase.searchHistoryList
        .where((item) => item.keyword == searchTextFieldController.text);
    if (searchHistory.length == 0) {
      TTBase.searchHistoryList.add(new SearchHistory(searchTextFieldController.text,  DateTime
          .now()
          .millisecondsSinceEpoch));

    }
    else {
      searchHistory.first.date = DateTime
          .now()
          .millisecondsSinceEpoch;
    }
    TTBase.searchHistoryList.sort((a, b) => (b.date).compareTo(a.date));
    LocalStorage.save('search_history',json.encode( TTBase.searchHistoryList));
    if (searchResultPage_LongVideo == null) {
      print('新建页面');
      searchResultPage_LongVideo = new SearchResultPage(
          childKey_LongVideo, searchTextFieldController.text,
          true, filterSort);
    } else {
      print('页面不为空');
      if (childKey_LongVideo.currentState != null) {
        print('无需新建页面');
        childKey_LongVideo.currentState.reSearch(
            searchTextFieldController.text, true, filterSort);
      } else {
        searchResultPage_LongVideo.offset = 0;
        searchResultPage_LongVideo.sort = 'default';
        searchResultPage_LongVideo.keyword = searchTextFieldController.text;
      }
    }
    if (searchResultPage_ShortVideo == null) {
      searchResultPage_ShortVideo = new SearchResultPage(
          childKey_ShortVideo, searchTextFieldController.text,
          false, filterSort);
    } else {
      if (childKey_ShortVideo.currentState != null) {
        childKey_ShortVideo.currentState.reSearch(
            searchTextFieldController.text, false, filterSort);
      } else {
        searchResultPage_ShortVideo.offset = 0;
        searchResultPage_ShortVideo.sort = 'default';
        searchResultPage_ShortVideo.keyword = searchTextFieldController.text;
      }
    }

    setState(() {
      showResultPage = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(

          title: Row(children: [
            InkWell(
              onTap: () {
                if (showResultPage) {
                  setState(() {
                    showResultPage = false;

                    searchTextFieldController.text = '';
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child:
              Container(

                child:
                SvgPicture.asset(
                  'images/common/goback.svg', height: dp(24), color: Theme
                    .of(context)
                    .textTheme
                    .bodyText1
                    .color,),
              ),),
            Padding(padding: EdgeInsets.only(left: dp(8))),
            Expanded(child: Container(
              decoration: new BoxDecoration(
                color: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .color
                    .withOpacity(0.15),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              alignment: Alignment.center,
              height: 36,
              child: TextField(
                  focusNode: focusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  controller: searchTextFieldController,
                  maxLines: 1,
                  autofocus: true,
                  onSubmitted: (value){
                    if(searchTextFieldController.text.length==0){return;}
                    filterSort=filterSortSelected='default';
                    if(_filterPanelOpacity>0){
                      _onFilterPanel();}

                    reSearch();
                  },
                  minLines: 1,
                  style: TextStyle(fontSize: 16),
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(

                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          .color,
                      fontSize: 16,
                    ),
                    prefixIconConstraints: BoxConstraints(
                    ),
                    prefixIcon: Container(
                        padding: EdgeInsets.only(left: dp(8), right: dp(8)),
                        child: SvgPicture.asset(
                          "images/common/search.svg", height: dp(20),
                          color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2
                              .color,)),
                    suffixIconConstraints: BoxConstraints(
                    ),
                    suffixIcon: Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: 8, end: _hasdeleteIcon ? 8 : 0),
                        child: _hasdeleteIcon
                            ?
                        InkWell(
                            onTap: () {
                              setState(() {
                                searchTextFieldController.text = '';
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
                                      .withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ), child: Container(
                              padding: EdgeInsets.all(dp(6)), child:
                            SvgPicture.asset(
                              'images/common/close.svg', height: 8,
                              color: Colors.white,),)))

                            : new Text('')),
                    contentPadding: EdgeInsets.all(0),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  onChanged: (str) {
                    setState(() {
                      if (str.isEmpty) {
                        _hasdeleteIcon = false;
                      } else {
                        _hasdeleteIcon = true;
                      }
                    });
                  },
                  onEditingComplete: onEditingComplete)
              ,
            ))
          ]),
          actions: <Widget>[
            InkWell(
                onTap: () async {
                  if(searchTextFieldController.text.length==0){return;}
                  filterSort=filterSortSelected='default';
                  if(_filterPanelOpacity>0){
                  _onFilterPanel();}

                reSearch();
                },
                child:
                Container(alignment: Alignment.center,
                  padding: EdgeInsets.only(right: dp(16)),
                  child: Text('搜索',
                    style: TextStyle(color: Colours.app_main, fontSize: 16),),))
          ],
//          brightness: Brightness.light,
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
          automaticallyImplyLeading: false,
//          leadingWidth: dp(24),
//          leading: InkWell(onTap: () {
//            Navigator.of(context).pop();
//          },
//              child: SvgPicture.asset(
//                    'images/common/goback.svg', height: dp(24), color: Theme
//                      .of(context)
//                      .textTheme
//                      .bodyText1
//                      .color,),
//          ),
        ),
        body: GestureDetector(onTap: () {
          focusNode.unfocus();
        }, child: Container(
            child: SafeArea(

                child:
                Container(
                    child: showResultPage ?
                    Stack(children: [
                      Container(padding: EdgeInsets.only(top:dp(40)),child: Column(children: [
                        Expanded(
                          child:Stack(children: [

                            TabBarView(
                            controller: resultTabControl,
                            children: [
                              searchResultPage_LongVideo,
                              searchResultPage_ShortVideo
                            ],
                          ),
                            _filterPanelOpacity==0?Padding(padding: EdgeInsets.zero,): AnimatedOpacity( duration: Duration(milliseconds: 200),
                        opacity: _filterPanelOpacity,
                        child:
                       InkWell(onTap: (){
                         _onFilterPanel();
                         filterSortSelected=filterSort;
                         setState(() {

                         });
                       },child: Container(color: Colors.black26)),
                            ),
                      AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          transform: __filterPanelTransform,
                          child: AnimatedOpacity(
                            opacity: _filterPanelOpacity,
                            duration: Duration(milliseconds: 100),
                            child:
Container(child:
                            Column(children: [

                              Container(color: Theme.of(context).backgroundColor,padding: EdgeInsets.only(left: dp(16),right: dp(16),top:dp(16),bottom: dp(16)),child: Row(children: [
                                Text('结果排序'),
                                Padding(
                                  padding: EdgeInsets.only(right: dp(8)),),
                                InkWell(onTap: (){
                                  setState(() {
                                    filterSortSelected='default';
                                  });

                                },child:
                                Container(padding: EdgeInsets.only(left:dp(8),right: dp(8),top:dp(6),bottom: dp(6)),
                                  decoration: new BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4)),
                                      color:filterSortSelected=='default'?Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(0.05):Colors.transparent
                                  ),
                                  child: Text('默认',style: TextStyle(fontWeight: filterSortSelected=='default'?FontWeight.bold:FontWeight.normal,color: filterSortSelected=='default'?Theme.of(context).textTheme.bodyText1.color:Theme.of(context).textTheme.subtitle2.color),),)),
                                InkWell(onTap: (){
                                  setState(() {
                                    filterSortSelected='hot';
                                  });

                                },child:
                                Container(
                                  margin: EdgeInsets.only(left: dp(8)),
                                  padding: EdgeInsets.only(left:dp(8),right: dp(8),top:dp(6),bottom: dp(6)),
                                  decoration: new BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4)),
                                      color:filterSortSelected=='hot'?Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(0.05):Colors.transparent
                                  ),
                                  child: Text('播放最多',style: TextStyle(fontWeight: filterSortSelected=='hot'?FontWeight.bold:FontWeight.normal,color: filterSortSelected=='hot'?Theme.of(context).textTheme.bodyText1.color:Theme.of(context).textTheme.subtitle2.color),),)),
                                InkWell(onTap: (){
                                  setState(() {
                                    filterSortSelected='new';
                                  });

                                },child:
                                Container(
                                  margin: EdgeInsets.only(left: dp(8)),
                                  padding: EdgeInsets.only(left:dp(8),right: dp(8),top:dp(6),bottom: dp(6)),
                                  decoration: new BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4)),
                                      color:filterSortSelected=='new'?Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(0.05):Colors.transparent
                                  ),
                                  child: Text('最新发布',style: TextStyle(fontWeight: filterSortSelected=='new'?FontWeight.bold:FontWeight.normal,color: filterSortSelected=='new'?Theme.of(context).textTheme.bodyText1.color:Theme.of(context).textTheme.subtitle2.color),),)),
                              ],),),
//                              Divider(color: ,),

                              Container(decoration: new BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  border: new Border(top:BorderSide(color:Theme.of(context).dividerTheme.color, width: 1))),child: Row(children: [
                                Expanded(child:
                                InkWell(
                                    onTap:(){
                                      _onFilterPanel();
                                      filterSortSelected=filterSort;
                                      setState(() {

                                      });
                              },
                                    child:
                                Container(
                                    padding: EdgeInsets.all(dp(16)),
                                    alignment: Alignment.center,
                                    child: Text('取消', style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),)))),
                                SizedBox(
                                  width: 0.5,
                                  height: dp(24),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Theme
                                            .of(context)
                                            .textTheme
                                            .subtitle2
                                            .color
                                            .withOpacity(0.2)),
                                  ),
                                ),
                                Expanded(child:
                                InkWell(
                                    onTap: (){
                                      filterSort=filterSortSelected;
                                      _onFilterPanel();


                                      reSearch();
                                    },
                                    child:
                                Container(
                                    padding: EdgeInsets.all(dp(16)),
                                    alignment: Alignment.center,
                                    child: Text('确定', style: TextStyle(
                                        color: Colours.app_main,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))))),
                              ],)),

                            ]))



                          )),
                          ],))



                      ])),
                      Container(height: dp(42),child: Column(children: [
                        Container(
                            alignment: Alignment.center
                            , color: Theme
                            .of(context)
                            .backgroundColor, padding: EdgeInsets.only(
                            left: dp(8), right: dp(16)), child:
                        SizedBox(height: dp(40), child:
                        Row(children: [

                          TabBar(
                            controller: resultTabControl,
                            indicator: RoundUnderlineTabIndicator(
                              wantWidth: 16,
                              borderSide: const BorderSide(
                                  width: 2.0, color: Colours
                                  .app_main),
                            ),
                            isScrollable: true,
                            //设置tab文字得类型
                            unselectedLabelStyle: TextStyle(
                              fontSize: 16,

                            ),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelColor: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .color,
                            //设置tab选中得颜色
                            labelColor: Colours.app_main,
                            //设置tab未选中得颜色
                            //设置自定义tab的指示器，CustomUnderlineTabIndicator
                            indicatorPadding: EdgeInsets.only(bottom: dp(4)),
                            //若不需要自定义，可直接通过
                            indicatorColor: Colours.app_main,
                            // 设置指示器颜色
                            indicatorWeight: 2,
                            labelPadding: EdgeInsets.only(
                                left: dp(8), right: dp(8)),
                            // 设置指示器厚度
                            //indicatorPadding
                            //indicatorSize  设置指示器大小计算方式
                            ///指示器大小计算方式，TabBarIndicatorSize.label跟文字等宽,TabBarIndicatorSize.tab跟每个tab等宽
                            indicatorSize: TabBarIndicatorSize.label,
                            //tabs: categoryList.map((e) => Tab(text: e.name)).toList(),
                            tabs: [Tab(text: '长视频',), Tab(text: '短视频',)],
                          ),
                          Expanded(child: InkWell(
                              onTap: () {
                                _onFilterPanel();
                                setState(() {

                                });
                              },
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text('筛选')))),

                        ],)
                        )),
                        Divider(height: 0.2,),
                      ],))
                    ])

:

                    SingleChildScrollView(
                      padding: EdgeInsets.only(left: dp(16), right: dp(16)),
                      child: Column(children: [

                        Padding(padding: EdgeInsets.only(top: dp(8)),),
                       TTBase.searchHistoryList.length>0? _searchHistory():Padding(padding: EdgeInsets.zero,),
                        _recommendKeywords(),
                        Padding(padding: EdgeInsets.only(top: dp(16)),),
                        _hotVideos()

                      ],),
                    )

                )
            )))


    );
  }


  _searchHistory() {
    if (visibleSearchHistorys.length < TTBase.searchHistoryList.length) {
      TTBase.searchHistoryList.sort((a, b) => (b.date).compareTo(a.date));
      if (TTBase.searchHistoryList.length > 2) {
        visibleSearchHistorys = TTBase.searchHistoryList.sublist(0, 2);
      } else {
        visibleSearchHistorys = TTBase.searchHistoryList;
      }
    }
    return
      Column(children: [
        Column(children: visibleSearchHistorys.map((item) {
          return
            Container(child:
            Row(crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: EdgeInsets.only(top: dp(8), bottom: dp(8)),
                    child: SvgPicture.asset(
                      'images/common/history.svg', height: dp(14), color: Theme
                        .of(context)
                        .textTheme
                        .bodyText2
                        .color,)),
                Padding(padding: EdgeInsets.only(right: dp(8))),
                Expanded(child: InkWell(onTap: () {
                  setState(() {
                    searchTextFieldController.text = item.keyword;
                  });

                  reSearch();
                }, child: Container(padding: EdgeInsets.only(
                    top: dp(8), bottom: dp(8)), child: Text(item.keyword,style: TextStyle(fontSize: 16),)))),
                InkWell(
                    onTap:()async{
                     TTBase.searchHistoryList.removeWhere((finditem) =>finditem.keyword==item.keyword );
                     LocalStorage.save('search_history',
                         json.encode(TTBase.searchHistoryList));
                     setState(() {

                     });
                    },
                    child:
                Container(
                    padding: EdgeInsets.only(top: dp(8), bottom: dp(8),left: dp(8)),
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.all(Radius
                        .circular(dp(8))))
                    ,
                    child: SvgPicture.asset(
                      'images/common/close.svg', color: Theme
                        .of(context)
                        .textTheme
                        .subtitle2
                        .color, height: dp(10),))),

              ],));
        }).toList()),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          InkWell(
              onTap: () {
                focusNode.unfocus();
                if (visibleSearchHistorys.length ==
                    TTBase.searchHistoryList.length) {
                  okCallBack() {
                    TTBase.searchHistoryList.clear();
                    LocalStorage.save('search_history',
                        json.encode(TTBase.searchHistoryList));
                    setState(() {
                      visibleSearchHistorys.clear();
                    });
                  }
                  TTDialog.showCustomDialog(
                      context, text: '是否清空全部搜索记录？', okCallBack: okCallBack);
                }
                else {
                  setState(() {
                    visibleSearchHistorys = TTBase.searchHistoryList;
                  });
                }
              }
              , child:
          Container(padding: EdgeInsets.only(top: dp(8), bottom: dp(16)),
            child: visibleSearchHistorys.length ==
                TTBase.searchHistoryList.length ?Row(children:[ SvgPicture.asset('images/common/delete.svg',height: 16,color: Theme.of(context).textTheme.subtitle2.color,),Padding(padding: EdgeInsets.only(left: dp(4))),Text('清除全部搜索记录',style:TextStyle(color: Theme.of(context).textTheme.subtitle2.color))]) :

            Row(children:[ SvgPicture.asset('images/common/expanddown.svg',height: 16,color: Theme.of(context).textTheme.subtitle2.color,),Padding(padding: EdgeInsets.only(left: dp(4))),Text('全部' + TTBase.searchHistoryList.length.toString() + '条搜索记录',style:TextStyle(color: Theme.of(context).textTheme.subtitle2.color))])
    ))],),
        Divider(color: Theme.of(context).dividerTheme.color,),
        Padding(padding: EdgeInsets.only(bottom: dp(16))),

      ]);
  }

  _recommendKeywords() {
    return Column(children: [
      Row(children: [
        Text(
          '猜你想搜', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              getRandomTagsRunning ? Lottie.asset(
                  'asset/loading.json', height: dp(24)) : Container(
                height: dp(24),),
              InkWell(onTap: () {
                getRandomTags();
              },
                  child: Container(
                    padding: EdgeInsets.all(dp(4)), child: Text('换一换',style:TextStyle(color: Theme.of(context).textTheme.subtitle2.color)),))
            ]))
      ],),
      Container(padding: EdgeInsets.only(top: dp(16)), child:
      hotTags == null ? Lottie.asset('asset/loading.json', height: dp(24)) :
      hotTags.length == 0 ? Container(padding: EdgeInsets.only(bottom: dp(16)),
        child: Text('暂无数据', style: TextStyle(color: Theme
            .of(context)
            .textTheme
            .subtitle2
            .color)),) : GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: TTBase.screenWidth / 2 / 32,
        crossAxisCount: 2,
        children: hotTags.map((item) {
          return InkWell(
              onTap: (){
                setState(() {
                  searchTextFieldController.text=item.tag;
                });


                reSearch();
              },
              child: Container(child: InkWell(child: Text(item.tag,style: TextStyle(fontSize: 16),),),));
        }).toList(),)),
      Padding(padding: EdgeInsets.only(bottom: dp(8))),
      Divider( color:Theme.of(context).dividerTheme.color,),
    ],);
  }

  _hotVideos() {
    return DefaultTabController(
        length: 3,
        child: Container(height: dp(1800), child:
        Column(
          children: <Widget>[
            TabBar(
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
              unselectedLabelColor: Theme
                  .of(context)
                  .textTheme
                  .bodyText1
                  .color,
              labelColor: Colours.app_main,
              indicatorPadding: EdgeInsets.only(bottom: dp(8)),
              indicatorColor: Colours.app_main,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: <Widget>[
                Tab(
                  text: "长视频榜",
                ),
                Tab(
                  text: "短视频榜",
                ),
                Tab(
                  text: "明星榜",
                )
              ],
            ),
            Expanded(flex: 1,
              child:
              Container( child:
              TabBarView(
                children: <Widget>[
                  (hotLongVideos == null ) ?Container(alignment: Alignment.topCenter,child: Lottie
                      .asset('asset/loading.json', height: dp(24))) : Column(
                      children:
                      hotLongVideos.asMap().map((index, item) {
                        return MapEntry(index,
                            InkWell(onTap: () {
                              focusNode.unfocus();
                              Navigator.pushNamed(context, '/longvideo_player',
                                  arguments: {
                                    'longVideoModel': item,
                                    'position': Duration.zero
                                  });
                            },child:
                            Container(
                            padding: EdgeInsets.only(bottom: dp(8),top: dp(8)),
                            child:
                            Row(children: [
                              Text((index+1).toString(), style: TextStyle(
                                  color: index>2?Theme.of(context).textTheme.subtitle2.color:Colours.app_main,
                                  fontWeight: FontWeight.bold),),
                              Padding(padding: EdgeInsets.only(left: dp(8))),
                              Expanded(child: Text(item.title,softWrap: true,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16),)),
                              Padding(padding: EdgeInsets.only(left: dp(8))),
                              SvgPicture.asset('images/common/goto.svg',height: dp(8),color:Theme.of(context).textTheme.subtitle2.color ,)],))));
                      }).values.toList()
                  ),
                  ( hotShortVideos == null) ?Container(alignment: Alignment.topCenter,child: Lottie
                      .asset('asset/loading.json', height: dp(24))) : Column(
                      children:
                      hotShortVideos.asMap().map((index, item) {
                        return MapEntry(index,
                            InkWell(onTap: () {
                              focusNode.unfocus();
                              Navigator.pushNamed(
                                  context, '/shortvideo_player', arguments:{'videoModel': item});

                            },child:
                            Container(
                                padding: EdgeInsets.only(bottom: dp(8),top: dp(8)),
                                child:
                                Row(children: [
                                  Text((index+1).toString(), style: TextStyle(
                                      color: index>2?Theme.of(context).textTheme.subtitle2.color:Colours.app_main,
                                      fontWeight: FontWeight.bold),),
                                  Padding(padding: EdgeInsets.only(left: dp(8))),
                                  Expanded(child: Text(item.title,softWrap: true,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16),)),
                                  Padding(padding: EdgeInsets.only(left: dp(8))),
                                  SvgPicture.asset('images/common/goto.svg',height: dp(8),color:Theme.of(context).textTheme.subtitle2.color ,)],))));
                      }).values.toList()
                  ),
                  (followTopUsers == null ) ?Container(alignment: Alignment.topCenter,child: Lottie
                      .asset('asset/loading.json', height: dp(24))) : Column(
                      children:
                      followTopUsers.asMap().map((index, item) {
                        return MapEntry(index,
                            InkWell(onTap: () {
                              focusNode.unfocus();
                              Navigator.pushNamed(
                                  context, '/user', arguments:{'user':item});

                            },child:
                            Container(
                                padding: EdgeInsets.only(bottom: dp(8),top: dp(8)),
                                child:
                                Row(children: [
                                  Text((index+1).toString(), style: TextStyle(
                                      color: index>2?Theme.of(context).textTheme.subtitle2.color:Colours.app_main,
                                      fontWeight: FontWeight.bold),),
                                  Padding(padding: EdgeInsets.only(left: dp(16))),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        32),
                                    child:
                                    Container(
                                        height: dp(32),
                                        width: dp(32),
                                        color:ThemeUtils.getLightBackgroundColor(context),
                                        child: CachedNetworkImage(
                                            fadeInDuration: Duration(milliseconds: 200),
                                            fit: BoxFit.cover,
                                            imageUrl: (TTBase.appConfig
                                                .res_server +
                                                'data/avatar/' +
                                                TTService.generate_MD5(
                                                    item.id.toString()) +
                                                '.dat'),
                                            cacheManager: CrpytAvatarCacheManager(),
                                            errorWidget: (
                                                BuildContext context,
                                                Object exception,
                                                StackTrace) {
                                              return SvgPicture.asset(
                                                'images/common/defaultavatar.svg',
                                                height: dp(32),
                                                width: dp(32),
                                                color: Theme
                                                    .of(context)
                                                    .textTheme.subtitle2.color.withOpacity(0.4),);
                                            })),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: dp(8))),
                                  Expanded(child: Text(item.username,softWrap: true,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16),)),
                                  Padding(padding: EdgeInsets.only(left: dp(8))),
                                  Text(TTService.formatNum(item.ext_info.fans).toString()+'粉丝')],))));
                      }).values.toList()
                  ),
                ],
              ),
              ),
            )
          ],)));
  }



  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;



}
