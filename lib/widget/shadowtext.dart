import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
class ShadowText extends StatelessWidget {
  ShadowText(this.data, { this.style,this.maxLines }) : assert(data != null);

  final String data;
  final TextStyle style;
   int maxLines=1;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          new Positioned(
            top:0.5,
            left: 0.5,
            child: new Text(
              data,
              style: style.copyWith(color: Colors.black.withOpacity(1)),
            ),
          ),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 0.5, sigmaY:0.5),
            child: new Text(data, style: style),
          ),
        ],
      ),
    );
  }
}