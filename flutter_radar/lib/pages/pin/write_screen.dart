// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/7
// Time  : 18:48
import 'package:flutter/material.dart';

class WriteScreen extends StatefulWidget {
  @override
  _WriteScreenState createState() => new _WriteScreenState();
}

class KanjiPainter extends ChangeNotifier implements CustomPainter {
  Color strokeColor;
  var strokes = new List<List<Offset>>();

  KanjiPainter(this.strokeColor);

  bool hitTest(Offset position) => null;

  void startStroke(Offset position) {
    print("startStroke");
    strokes.add([position]);
    notifyListeners();
  }

  void appendStroke(Offset position) {
    print("appendStroke");
    strokes.last.add(position);
    notifyListeners();
  }

  void endStroke() {
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("paint!");
    var rect = Offset.zero & size;
    Paint fillPaint = new Paint()
      ..color = Colors.yellow[100]
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    Paint strokePaint = new Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      Path strokePath = new Path();
      // Iterator strokeIt = stroke.iterator..moveNext();
      // Offset start = strokeIt.current;
      // strokePath.moveTo(start.dx, start.dy);
      // while (strokeIt.moveNext()) {
      //   Offset off = strokeIt.current;
      //   strokePath.addP
      // }
      strokePath.addPolygon(stroke, false);
      canvas.drawPath(strokePath, strokePaint);
    }
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  // TODO: implement semanticsBuilder
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    // TODO: implement shouldRebuildSemantics
    return null;
  }
}

class _WriteScreenState extends State<WriteScreen> {
  KanjiPainter kanjiPainter;

  void panStart(DragStartDetails details) {
    print(details.globalPosition);
    kanjiPainter.startStroke(details.globalPosition);
  }

  void panUpdate(DragUpdateDetails details) {
    print(details.globalPosition);
    kanjiPainter.appendStroke(details.globalPosition);
  }

  void panEnd(DragEndDetails details) {
    kanjiPainter.endStroke();
  }

  @override
  void initState() {
    super.initState();
    kanjiPainter = new KanjiPainter(const Color.fromRGBO(255, 255, 255, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text("Draw!")),
      backgroundColor: const Color.fromRGBO(200, 200, 200, 1.0),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: CustomPaint(
                painter: kanjiPainter,
                child: GestureDetector(
                  onPanStart: panStart,
                  onPanUpdate: panUpdate,
                  onPanEnd: panEnd,
                ),
                // child: new Text("Custom Painter"),
                // size: const Size.square(100.0),
              ))),
    );
  }
}
