import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_manhuatai/common/model/satellite.dart';
import 'package:flutter_manhuatai/models/user_role_info.dart' as UserRoleInfo;

import 'package:flutter_manhuatai/components/load_more_widget/load_more_widget.dart';
import 'package:flutter_manhuatai/components/satellite_header/satellite_header.dart';
import 'package:flutter_manhuatai/components/satellite_content/satellite_content.dart';
import 'package:flutter_manhuatai/pages/search_result/components/related_header.dart';
import 'package:flutter_manhuatai/routes/application.dart';
import 'package:flutter_manhuatai/routes/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

typedef void ItemCallBack(Satellite item, int index);

class RecommendSatelliteSliverList extends StatelessWidget {
  final int satelliteCount;
  final bool isRelated;
  final List<Satellite> recommendSatelliteList;
  final List<UserRoleInfo.Data> userRoleInfoList;
  final bool hasMore;
  final ItemCallBack supportSatellite;
  final ItemCallBack updateSatellite;

  RecommendSatelliteSliverList({
    this.satelliteCount,
    this.isRelated = false,
    this.recommendSatelliteList,
    this.userRoleInfoList,
    this.hasMore,
    this.supportSatellite,
    this.updateSatellite,
  });

  Future<void> navigateToSatelliteDetail(
    BuildContext context,
    Satellite item,
    int index,
  ) async {
    Satellite _satellite = await Application.router.navigateTo(
      context,
      '${Routes.satelliteDetail}?satelliteId=${item.id}',
    );
    if (_satellite != null) {
      updateSatellite(_satellite, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            if (isRelated) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                ),
                child: RelatedHeader(
                  title: '相关帖子($satelliteCount)',
                  showAll: satelliteCount > 10,
                  onTap: () {
                    showToast('TODO: 跳转查看全部的相关帖子');
                  },
                ),
              );
            }
            return Container();
          }

          if (index == recommendSatelliteList.length + 1) {
            return LoadMoreWidget(
              hasMore: hasMore,
            );
          }

          var item = recommendSatelliteList[index - 1];
          UserRoleInfo.Data roleInfo;
          roleInfo = userRoleInfoList.firstWhere(
            (userRole) {
              return item.useridentifier == userRole.userId;
            },
            orElse: () => null,
          );

          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: ScreenUtil().setWidth(30),
                  bottom: ScreenUtil().setWidth(20),
                ),
                child: SatelliteHeader(
                  item: item,
                  roleInfo: roleInfo,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  navigateToSatelliteDetail(context, item, index);
                },
                child: SatelliteContent(
                  item: item,
                  supportSatellite: () {
                    supportSatellite(item, index);
                  },
                ),
              ),
            ],
          );
        },
        childCount: recommendSatelliteList.length + 2,
      ),
    );
  }
}
