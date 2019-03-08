import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Fresh extends StatefulWidget {
  _Fresh createState() => _Fresh();
}

class _Fresh extends State<Fresh> with SingleTickerProviderStateMixin, TickerProviderStateMixin {

  double headerHeight;
  double start, end;
  AnimationController controller;
  Animation<double> tween;
  ScrollController scrollController = ScrollController(); // 列表滚动监听

  void initState() {
    super.initState();
    headerHeight = 0.0;
    controller = AnimationController(
        duration: Duration(milliseconds: 100),
        vsync: this
    );
    tween = new Tween(begin: 0.0, end: 100.0)
        .animate(controller)
      ..addListener(() {
        setState(() {

        });
      });
    scrollController.addListener(() {
      print('scrolling');
    });
  }

  void _handleScrollUpdateNotification(ScrollUpdateNotification nt) {
    if (nt.dragDetails == null) {
      return;
    }
    if (scrollController.position.pixels == 0) {
      print('is pushing');
    }
  }

  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.black,
              height: headerHeight,
            ),
            Expanded(
              child: NotificationListener(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.green,
                      height: 50,
                      margin: EdgeInsets.only(bottom: 15),
                    );
                  },
                  itemCount: 20,
                  controller: scrollController,
                ),
                onNotification: (ScrollNotification notification) {
                  ScrollMetrics metrics = notification.metrics;
                  if (notification is ScrollUpdateNotification) {
                    _handleScrollUpdateNotification(notification);
                  } else if (notification is ScrollEndNotification) {

                  } else if (notification is UserScrollNotification) {

                  } else if (metrics.atEdge && notification is OverscrollNotification) {

                  }
                  return true;
                },
              ),
            ),
          ],
        )
    );
  }
}