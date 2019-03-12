import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Fresh extends StatefulWidget {
  _Fresh createState() => _Fresh();
}

class _Fresh extends State<Fresh> with SingleTickerProviderStateMixin, TickerProviderStateMixin {

  bool pullEnable;
  ScrollPhysics scrollPhysics = NeverScrollableScrollPhysics();
  double headerHeight;
  double start, end;
  AnimationController controller;
  Animation<double> tween;
  ScrollController scrollController = ScrollController(); // 列表滚动监听

  void initState() {
    super.initState();
    pullEnable = true;
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

  void _setPhysics(ScrollPhysics physics) {
    setState(() {
      scrollPhysics = physics;
    });
  }

  //
  void _handleScrollUpdateNotification(ScrollUpdateNotification nt) {
    if (nt.dragDetails == null) {
      return;
    }
    if (headerHeight > 0.0) {
      setState(() {
        double pushHeight = nt.dragDetails.delta.dy;
        if (pushHeight / 2 + headerHeight <= 0.0) {
          headerHeight = 0.0;
          _setPhysics(RefreshAlwaysScrollPhysics());
        } else {
          headerHeight =headerHeight + pushHeight / 2;
        }
      });
    }
  }

  // 拖动结束
  void _handleScrollEndNotification() {
    // 拖动结束时判断headerHeight的距离,当大于可刷新距离时，开启刷新，关闭刷新锁避免垃圾刷新
    // 若未达到刷新距离，则调用forward，重置为0
  }

  //
  void _handleUserScrollNotification(UserScrollNotification nt) {
    if(headerHeight >0.0 && nt.direction == ScrollDirection.reverse){
      //头部刷新布局出现反向滑动时（由下向上）
      _setPhysics(RefreshScrollPhysics());
    }
  }

  //
  void _handleOverscrollNotification(OverscrollNotification nt) {
    if (nt.dragDetails == null) {
      return;
    }
    if (nt.overscroll < 0.0) {
      double pushHeight = nt.dragDetails.delta.dy;
      setState(() {
        if (pushHeight / 2 + headerHeight <= 0.0) {
          headerHeight = 0.0;
          _setPhysics(new RefreshAlwaysScrollPhysics());
        }
        if (headerHeight > 150.0) {
          _setPhysics(NeverScrollableScrollPhysics());
          headerHeight = pushHeight / 6 + headerHeight;
        } else if (headerHeight > 120.0) {
          headerHeight = pushHeight / 4 + headerHeight;
        } else if (headerHeight > 80) {
          headerHeight = pushHeight / 2 + headerHeight;
        } else {
          headerHeight = pushHeight + headerHeight;
        }
      });
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
                  _handleScrollEndNotification();
                } else if (notification is UserScrollNotification) {
                  _handleUserScrollNotification(notification);
                } else if (metrics.atEdge && notification is OverscrollNotification) {
                  _handleOverscrollNotification(notification);
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


///切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
///出现反向滑动时用此ScrollPhysics
class RefreshScrollPhysics extends ScrollPhysics {
  const RefreshScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }


  ///防止ios设备上出现弹簧效果
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
                'The proposed new position, $value, is exactly equal to the current position of the '
                'given ${position.runtimeType}, ${position.pixels}.\n'
                'The applyBoundaryConditions method should only be called when the value is '
                'going to actually change the pixels, otherwise it is redundant.\n'
                'The physics object in question was:\n'
                '  $this\n'
                'The position object in question was:\n'
                '  $position\n'
        );
      }
      return true;
    }());
    if (value < position.pixels && position.pixels <= position.minScrollExtent) // underscroll
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
      return value - position.pixels;
    if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }



  //重写这个方法为了减缓ListView滑动速度
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if(offset<0.0){
      return 0.00000000000001;
    }
    if(offset==0.0){
      return 0.0;
    }
    return offset/2;
  }


  //此处返回null时为了取消惯性滑动
  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    return  null;
  }
}
///切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
///此类用来控制IOS过度滑动出现弹簧效果
class RefreshAlwaysScrollPhysics extends AlwaysScrollableScrollPhysics {
  const RefreshAlwaysScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  RefreshAlwaysScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshAlwaysScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }

  ///防止ios设备上出现弹簧效果
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
                'The proposed new position, $value, is exactly equal to the current position of the '
                'given ${position.runtimeType}, ${position.pixels}.\n'
                'The applyBoundaryConditions method should only be called when the value is '
                'going to actually change the pixels, otherwise it is redundant.\n'
                'The physics object in question was:\n'
                '  $this\n'
                'The position object in question was:\n'
                '  $position\n'
        );
      }
      return true;
    }());
    if (value < position.pixels && position.pixels <= position.minScrollExtent) // underscroll
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
      return value - position.pixels;
    if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }

  ///防止ios设备出现卡顿
  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double end;
      if (position.pixels > position.maxScrollExtent)
        end = position.maxScrollExtent;
      if (position.pixels < position.minScrollExtent)
        end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(
          spring,
          position.pixels,
          position.maxScrollExtent,
          math.min(0.0, velocity),
          tolerance: tolerance
      );
    }
    if (velocity.abs() < tolerance.velocity)
      return null;
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent)
      return null;
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent)
      return null;
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
