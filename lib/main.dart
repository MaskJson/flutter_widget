import 'package:flutter/material.dart';
import 'menu/bin.dart';
import 'menu/view.dart';
import 'fresh/fresh.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ScrollController controller = ScrollController();
  List<ItemData> data = [];
  void initState() {
    super.initState();
    data.add(ItemData(name: 'One', height: 200, selected: 0));
    data.add(ItemData(name: 'Two', height: 400, selected: 200));
    data.add(ItemData(name: 'Three', height: 200, selected: 600));
    data.add(ItemData(name: 'Four', height: 300, selected: 800));
    data.add(ItemData(name: 'Five', height: 150, selected: 1100));
    data.add(ItemData(name: 'Six', height: 200, selected: 1150));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
//        body: AdsView(
//          data: data,
//          controller: controller,
//          titleHeight: 50,
//          titleWidget: (ItemData item, double offset) {
//            return TitleWidget(item, offset);
//          },)
      body: Fresh(),
    );
  }
}

class TitleWidget extends StatelessWidget {
  final ItemData obj;
  final double offset;
  TitleWidget(this.obj, this.offset);
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0.0, offset, 0.0),
      height: 50,
      color: Colors.black,
      child: Text(obj.name, style: TextStyle(color: Colors.white),),
    );
  }
}