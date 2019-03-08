import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_manhuatai/pages/home/home_index.dart';
import 'package:flutter_manhuatai/pages/update/update.dart';
import 'package:flutter_manhuatai/pages/manhuatai/manhuatai.dart';
import 'package:flutter_manhuatai/pages/bookshelf/bookshelf.dart';
import 'package:flutter_manhuatai/pages/mine/mine.dart';

import 'package:flutter_manhuatai/components/bottom_navigation/bottom_navigation.dart';

class MyHomePage extends StatefulWidget {
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  PageController _controller = PageController(initialPage: 0);
  List<Widget> pages = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    pages
      ..add(HomeIndex())
      ..add(HomeUpdate())
      ..add(HomeManhuatai())
      ..add(HomeBookshelf())
      ..add(HomeMine());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  onChangeIndex(int index) {
    _controller.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
          ..init(context);

    return Scaffold(
      body: PageView(
        controller: _controller,
        children: pages,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onChangeIndex: onChangeIndex,
      ),
    );
  }
}
