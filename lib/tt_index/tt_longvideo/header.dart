import 'dart:math';
import 'dart:ui';
import 'dart:io';

import '../../bloc.dart';
import '../../res/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:barcode_scan/barcode_scan.dart';
// import 'package:flutter/services.dart';

import '../../base.dart';
import '../../service.dart';

class Header extends StatefulWidget {
  final num height;
  final num opacity;
  final BoxDecoration decoration;
  Header({ this.height, this.opacity = 1.0, this.decoration });

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TTBase {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      height: widget.height != null ? widget.height : TTBase.statusBarHeight +
          dp(48),
      width: screenWidth,
      color: Colours.app_main,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            bottom: dp(12),
            child: SizedBox(
              width: screenWidth - dp(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                      flex: 1,

                      child: Container(
                        height: dp(32),
                        padding: EdgeInsets.only(left: dp(4), right: dp(4)),
                        decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .backgroundColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(dp(20)),
                          ),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          readOnly: true,
                          autofocus: false,
                          onTap: () {
                            Navigator.pushNamed(context, '/search');
                          },
                          minLines: 1,
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: TTBase.hotTags.length > 2 ? TTBase
                                .hotTags[0].tag + ' I ' + TTBase.hotTags[1 +
                                new Random().nextInt(TTBase.hotTags.length - 1)]
                                .tag : '输入视频名称/标签进行搜索',
                            hintStyle: TextStyle(
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1
                                  .color,
                              fontSize: 14,
                            ),
                            prefixIconConstraints: BoxConstraints(
                            ),
                            prefixIcon: Container(
                                padding: EdgeInsets.only(
                                    left: dp(8), right: dp(8)),
                                child: SvgPicture.asset(
                                  "images/common/search.svg", height: dp(16),
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,)),

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
                        ),
                      )),
                  InkWell(onTap: () {
                    if (TTService.checkLogin(context)) {
                      Navigator.pushNamed(context, '/playrecord');
                    }
                  }, child:
                  Padding(
                      padding: EdgeInsets.only(left: dp(8)),
                      child: SvgPicture.asset(
                          'images/my/playrecord.svg', height: dp(24),
                          color: Colors.white)
                  )),
                  InkWell(onTap: () {
    if (TTService.checkLogin(context)) {
      Navigator.pushNamed(context, '/upload/selectvideo');
    }
                  }, child:
                  Padding(
                      padding: EdgeInsets.only(left: dp(8)),
                      child: SvgPicture.asset(
                          'images/common/camera.svg', height: dp(24),
                          color: Colors.white)
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}