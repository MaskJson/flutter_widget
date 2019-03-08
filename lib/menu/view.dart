import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'bin.dart';

typedef Widget GetTitleWidget<ItemData>(ItemData item, double offset);

class AdsView extends StatefulWidget {
  final List<ItemData> data;
  final GetTitleWidget<ItemData> titleWidget;
  final ScrollController controller;
  final double cacheExtent;
  final double titleHeight;
  AdsView({
    @required this.data,
    @required this.titleWidget,
    @required this.titleHeight,
    @required this.controller,
    this.cacheExtent: 30.0,
  }) : assert(
    data != null
  );
  _AdsViewState createState() => _AdsViewState();
}

class _AdsViewState extends State<AdsView> {

  List<double> selectedHeights = [];
  ScrollController scrollController;
  int index = 0;
  double headerOffset = 0.0;
  ItemData headerMap;
  double beforeScroll = 0.0; // 前一个title的selectedHeight
  ScrollPhysics scrollPhysics = ClampingScrollPhysics();

  void initState() {
    super.initState();
    headerMap = widget.data.first;
    widget.data.forEach((item) {
      selectedHeights.add(item.selected);
    });
    // 滚动监听，重置吸附title
    widget.controller.addListener(() {
      // 计算滑动了多少距离
      double pixels = widget.controller.position.pixels;
      // 计算当前第一个可见的item的下标
      int a = selectedHeights.indexWhere((selectedHeight) {
        return pixels < (selectedHeight - widget.titleHeight);
      });
      a--;
      setState(() {
        index = a;
      });
      // 当再向上滑当前item不可视时，提前改变偏移量
      setState(() {
        double val = pixels - selectedHeights[a] + widget.titleHeight;
        // 当刚好移动到两个item收尾相接处
        double val2 = pixels - selectedHeights[a];
        if (val >= 0 && val <= widget.titleHeight || val2 != null && val2 >= -widget.titleHeight && val2 < 0) {
          if (val == widget.titleHeight) {
            headerMap = widget.data[a];
          } else if(val2 != null && val2 >= -widget.titleHeight && val2 < 0) {
            headerMap = widget.data[a - 1];
          }
          headerOffset = -val; // 当下一个item到吸附title底部时，开始偏移
        } else {
          headerMap = widget.data[a];
          headerOffset = 0.0;
        }
      });
    });
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
          physics: scrollPhysics,
          cacheExtent: 100.0,
          controller: widget.controller,
          itemBuilder: (context, index) {
            return new Container(
              color: Colors.black12,
              height: widget.data[index].height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 50,
                    color: Colors.black,
                    child: Text(widget.data[index].name, style: TextStyle(color: Colors.white),),
                  )
                ],
              ),
            );
          },
          itemCount: widget.data.length,
        ),
        GestureDetector(
          onTap: () {
            // 吸附title点击滚动操作
            widget.controller.animateTo(selectedHeights[index], duration: Duration(milliseconds: 100), curve: Curves.linear);
          },
          child: widget.titleWidget(headerMap, headerOffset),
        )
      ],
    );
  }

}