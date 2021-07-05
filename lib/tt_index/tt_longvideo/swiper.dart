import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc.dart';
import '../../base.dart';

class SwiperList extends StatelessWidget with TTBase {

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: TTBase.dessignWidth)..init(context);

    return BlocBuilder<IndexBloc, Map>(
        builder: (ctx, indexState) {
          List swiperPic = indexState['swiper'];
          return Padding(
            padding: EdgeInsets.only(bottom:dp(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(dp(10)),
              ),
              child: Container(
                height: dp(130),
                child: _waitSwiperData(context,swiperPic),
              ),
            ),
          );
        }
    );
  }

  Widget _waitSwiperData(context,swiperPic) {
    if (swiperPic == null) {
      return Image.asset(
        'images/image_default.png',
        fit: BoxFit.fill,
      );
    } else if (swiperPic.length > 0) {
      return Swiper(
        itemBuilder: (BuildContext context, int index) =>
          InkWell(
              onTap: (){

              },
              child:
              CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 200),
          imageUrl: swiperPic[index],
          placeholder: (context, url) => Image.asset(
            'images/image_default.png',
            fit: BoxFit.fill,
          ),
          fit: BoxFit.cover,
        )),
        itemCount: swiperPic.length,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              color: Colors.white,
              size: dp(6),
              activeSize: dp(9),
              activeColor: TTBase.defaultColor,
            ),
            margin: EdgeInsets.only(
              right: dp(10),
              bottom: dp(5),
            ),
            alignment: Alignment.bottomRight
        ),
        scrollDirection: Axis.horizontal,
        autoplay: true,
        onTap: (index)=>(){

        });

    }

    return null;
  }

}