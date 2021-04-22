import 'dart:async';

import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screen_saver/game_canvas_engine.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'スクリーンセーバ',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class WorksData {
  final String name;
  final String link;
  final Color color;
  WorksData(this.name,this.link,this.color);
}
var works = [
  WorksData("クラタン", "https://pizzxa.fastriver.dev/apps/cloud-tango/jp", Colors.amber),
  WorksData("動物将棋", "https://doubutsu.fastriver.dev/", Colors.deepPurple.shade500),
  WorksData("年賀状(ね)", "https://year-greeting-condition2020.fastriver.dev/", Colors.blueGrey),
  WorksData("FactMemory", "https://play.google.com/store/apps/details?id=com.companyname.FactMemory&hl=ja", Colors.blue.shade800),
  WorksData("つらたん", "https://tsuratan.fastriver.dev/", Colors.grey),
  WorksData("2020new", "https://kcs1959.github.io/2020new/", Colors.blueAccent.shade700),
  WorksData("YuDoFu", "https://yudofu.fastriver.dev/", Colors.lightBlue),
  WorksData("蜿", "https://en.fastriver.dev/", Colors.red.shade900)
];

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GameCanvasEngine engine;
  ScrollController controller;
  LogoObject logo;
  int worksIndex = 0;
  double itemHeight = 0;
  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(() {
    });
    engine = GameCanvasEngine(update);
    logo = LogoObject(200, 100, 200, -5, 5)
      ..reflectedListener = reflected
      ..color = Colors.lightBlue;
    engine.addObject(logo);
    engine.resumeEngine();
  }

  @override
  void dispose() {
    engine.dispose();
    controller.dispose();
    super.dispose();
  }

  void update(Timer timer, List<GameObject> objects, Size canvasSize) {
    //print("update: $canvasSize ${objects.length}");
    if(canvasSize == null) return;
    objects.forEach((element) {
      if(element is LogoObject) element.update(canvasSize);
    });
    engine.notify();
  }

  void reflected() {
    worksIndex++;
    if(worksIndex >= works.length) worksIndex = 0;
    logo.color = works[worksIndex].color;
    controller.animateTo(worksIndex * itemHeight, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          var viewWidth = constraints.biggest.width;
          var viewHeight = constraints.biggest.height;
          itemHeight = viewHeight * 0.3;
          engine.setCanvasSize(constraints.biggest);
          return Stack(
            children: [
              Positioned.fill(
                child: ScreenSaverCanvas(
                  engine: engine,
                )
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 64,
                child: Container(
                  width: viewWidth * 0.6,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ClickableListWheelScrollView(
                      scrollController: controller,
                      itemHeight: itemHeight,
                      itemCount: works.length,
                      onItemTapCallback: (index) async {
                        if(index == worksIndex) {
                          var url = works[index].link;
                          if(await canLaunch(url)) await launch(url);
                        }
                      },
                      child: ListWheelScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: controller,
                        itemExtent: itemHeight,
                        overAndUnderCenterOpacity: 0.2,
                        renderChildrenOutsideViewport: true,
                        clipBehavior: Clip.none,
                        offAxisFraction: 1.0,
                        diameterRatio: 3,
                        children: works.map((e) => wheelItem(e.name, viewWidth, viewHeight)).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Text(
                      "©fastriver_org 2021",
                      style: TextStyle(color: Colors.white54),
                    ),
                    InkWell(
                      onTap: () {
                        showLicensePage(context: context);
                      },
                      child: Text(
                        "License",
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }
      )
    );
  }

  Widget wheelItem(String text, double viewWidth, double viewHeight) {
    return Container(
        width: viewWidth * 0.6,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(text, style: TextStyle(fontSize: viewHeight * 0.15, color: Colors.white24), textAlign: TextAlign.end,),
        )
    );
  }
}

class ScreenSaverCanvas extends StatelessWidget {
  final GameCanvasEngine engine;
  ScreenSaverCanvas({Key key, this.engine}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(),
      painter: ScreenSaverPainter(
        engine
      ),
    );
  }
}

class ScreenSaverPainter extends CustomPainter {
  GameCanvasEngine engine;
  ScreenSaverPainter(this.engine): super(repaint: engine);
  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint();
    p.color = Color(0xFF121212);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), p);
    engine?.gameObjects?.forEach((element) {
      element.paint(canvas);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
