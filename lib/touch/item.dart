import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  final double height;
  Item({this.height: 60});
  ItemState createState() => ItemState();
}

class ItemState extends State<Item> {
  double left;
  double start;
  bool flag;
  void initState() {
    super.initState();
    left = 0.0;
  }
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: widget.height,
      child: Stack(
        overflow: Overflow.clip,
        children: <Widget>[
          Container(
          ),
          Positioned(
            left: left,
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
                onHorizontalDragStart: (details) {
                  setState(() {
                    left = 0;
                  });
                  setState(() {
                    start = details.globalPosition.dx;
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
                  setState(() {
                    left = -l;
                  });
                },
                onHorizontalDragEnd: (details) {
                  double v = start - details.velocity.pixelsPerSecond.dx;
                  if (v > 30) {
                    setState(() {
                      left = -60;
                    });
                  } else {
                    setState(() {
                      left = 0;
                    });
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}