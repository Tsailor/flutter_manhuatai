import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_manhuatai/components/image_wrapper/image_wrapper.dart';

import 'package:flutter_manhuatai/models/book_list.dart';
import 'package:flutter_manhuatai/utils/utils.dart';

class BookItemContent extends StatelessWidget {
  final double width;
  final double horizonratio;
  final Comic_info item;
  final Config config;

  BookItemContent({
    this.width,
    this.horizonratio,
    this.item,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ImageWrapper(
            url: Utils.formatBookImgUrl(
              comicInfo: item,
              config: config,
            ),
            width: width,
            height: width / horizonratio,
            fit: BoxFit.fill,
          ),
          Container(
            margin: EdgeInsets.only(
              right: ScreenUtil().setWidth(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildComicName(),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(10),
                  ),
                  child: Text(
                    item.content,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: ScreenUtil().setSp(20),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildComicName() {
    TextStyle style = TextStyle(
      color: Colors.black,
      fontSize: ScreenUtil().setSp(28),
    );

    // displayType == 11 时，在漫画名字前面增加漫画的类型
    if (config.displayType == 11 && item.comicType.first.isNotEmpty) {
      return Container(
        padding: EdgeInsets.only(
          top: ScreenUtil().setWidth(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(10),
                horizontal: ScreenUtil().setWidth(12),
              ),
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(18),
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[400],
                  width: ScreenUtil().setWidth(1),
                ),
                borderRadius: BorderRadius.circular(
                  ScreenUtil().setWidth(25),
                ),
              ),
              child: Text(
                item.comicType.first,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: ScreenUtil().setSp(20),
                  height: 1.0,
                ),
              ),
            ),
            Expanded(
              child: Text(
                item.comicName,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(16),
      ),
      child: Text(
        item.comicName,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}