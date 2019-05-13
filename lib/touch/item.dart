import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  final double height;
  Item({this.height: 60});
  ItemState createState() => ItemState();
}

class ItemState extends State<Item> with TickerProviderStateMixin {
  double left;
  double start;
  bool moving;
  AnimationController controller;
  Animation<double> tween;
  AnimationController slowController;
  void initState() {
    super.initState();
    left = 0.0;
    controller = AnimationController(
        duration: Duration(milliseconds: 0),
        vsync: this
    );
    tween = new Tween(begin: 0.0, end: 0.0)
        .animate(controller)
      ..addListener(() {
        setState(() {

        });
      });
  }
  void animation(bool slow, double end) {
    controller.duration = Duration(milliseconds: (slow || !moving) ? 5000 : 0);
    setState(() {
      tween = new Tween(begin: tween.value, end: end)
          .animate(controller)
        ..addListener(() {

        });
      print(tween.value);
    });
    controller.forward();
  }
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: widget.height,
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            Container(
              // 这里可用list-item widget代替
            ),
            Positioned(
              left: tween.value,
              child: Container(
                width: width,
                height: widget.height,
                child: GestureDetector(
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Container(
                        color: Colors.black12,
                      ),
                      Positioned(
                        right: -60,
                        top: 0,
                        child: Container(
                          width: 60,
                          height: widget.height,
                          alignment: Alignment.center,
                          color: Colors.red,
                          child: InkWell(
                            child: Text('remove'),
                          ),
                        ),
                      )
                    ],
                  ),
                  onTapDown: (details) {
                    animation(true, 0);
                  },
                  onHorizontalDragStart: (details) {
                    setState(() {
                      start = details.globalPosition.dx;
                      moving = true;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    double v = start - details.globalPosition.dx;
                    double l;
                    if (v >= 0 && v <= 60) {
                      l = v;
                    } else if (v < 0) {
                      l = 0;
                    } else {
                      l = 60;
                    }
                    animation(false, -l);
                    setState(() {
                      left = -l;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    double v = -left;
                    if (v > 30) {
                      v = -60;
                    } else {
                      v = 0;
                    }
                    setState(() {
                      left = v;
                      moving = false;
                    });
                    animation(true, v);
                    setState(() {
                      left = 0;
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}