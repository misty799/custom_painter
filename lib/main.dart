import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();
  Color pickerColor = Colors.black;
  Color pickerBackground = Colors.white;
  List<TouchPoints> points = List();
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;
  Color selectedColor = Colors.black;
  Color selectedBackground = Colors.white;

  Future<void> _pickStroke() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClipOval(
          child: AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  strokeWidth = 3.0;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Icon(
                  Icons.brush,
                  size: 24,
                ),
                onPressed: () {
                  strokeWidth = 10.0;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Icon(
                  Icons.brush,
                  size: 40,
                ),
                onPressed: () {
                  strokeWidth = 30.0;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Icon(
                  Icons.brush,
                  size: 60,
                ),
                onPressed: () {
                  strokeWidth = 50.0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _opacity() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClipOval(
          child: AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Icon(
                  Icons.opacity,
                  size: 24,
                ),
                onPressed: () {
                  opacity = 0.1;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Icon(
                  Icons.opacity,
                  size: 40,
                ),
                onPressed: () {
                  opacity = 0.5;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Icon(
                  Icons.opacity,
                  size: 60,
                ),
                onPressed: () {
                  opacity = 1.0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    if (!(await Permission.storage.status.isGranted))
      await Permission.storage.request();

    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 60,
        name: "canvas_image");
    print(result);
  }

  List<Widget> fabOption() {
    return <Widget>[
      FloatingActionButton(
        heroTag: "paint_save",
        child: Icon(Icons.save),
        tooltip: 'Save',
        onPressed: () {
          //min: 0, max: 50
          setState(() {
            _save();
            displayDialog(context);
          });
        },
      ),
      FloatingActionButton(
        heroTag: "paint_stroke",
        child: Icon(Icons.brush),
        tooltip: 'Stroke',
        onPressed: () {
          //min: 0, max: 50
          setState(() {
            _pickStroke();
          });
        },
      ),
      FloatingActionButton(
        heroTag: "paint_opacity",
        child: Icon(Icons.opacity),
        tooltip: 'Opacity',
        onPressed: () {
          //min:0, max:1
          setState(() {
            _opacity();
          });
        },
      ),
      FloatingActionButton(
          heroTag: "background",
          child: Icon(FlutterIcons.alpha_b_box_mco),
          tooltip: 'Opacity',
          onPressed: () {
            Color pickerBackground = selectedBackground;
            Navigator.of(context)
                .push(new MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return new Scaffold(
                          appBar: new AppBar(
                            title: const Text('Pick color'),
                          ),
                          body: new Container(
                              alignment: Alignment.center,
                              child: new ColorPicker(
                                pickerColor: pickerBackground,
                                onColorChanged: (Color c) =>
                                    pickerBackground = c,
                              )));
                    }))
                .then(
              (_) {
                setState(() {
                  selectedBackground = pickerBackground;
                });
              },
            );
          }),
      FloatingActionButton(
          heroTag: "erase",
          child: Icon(Icons.clear),
          tooltip: "Erase",
          onPressed: () {
            setState(() {
              points.clear();
            });
          }),
      FloatingActionButton(
          backgroundColor: Colors.blue,
          heroTag: "color_red",
          child: Icon(Icons.color_lens),
          tooltip: 'Color',
          onPressed: () {
            Color pickerColor = selectedColor;
            Navigator.of(context)
                .push(new MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return new Scaffold(
                          appBar: new AppBar(
                            title: const Text('Pick color'),
                          ),
                          body: new Container(
                              alignment: Alignment.center,
                              child: new ColorPicker(
                                pickerColor: pickerColor,
                                onColorChanged: (Color c) => pickerColor = c,
                              )));
                    }))
                .then(
              (_) {
                setState(() {
                  selectedColor = pickerColor;
                });
              },
            );
          })
    ];
  }
   Future<void> displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your Painting has been saved in custom_painting folder'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('okay')),]);});}
              

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title:Text('Custom Painter'),),
        backgroundColor: pickerBackground,
        body: Container(
          color: Colors.white,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject();
                points.add(TouchPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: Paint()
                      ..strokeCap = strokeType
                      ..isAntiAlias = true
                      ..color = selectedColor.withOpacity(opacity)
                      ..strokeWidth = strokeWidth));
              });
            },
            onPanStart: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject();
                points.add(TouchPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: Paint()
                      ..strokeCap = strokeType
                      ..isAntiAlias = true
                      ..color = selectedColor.withOpacity(opacity)
                      ..strokeWidth = strokeWidth));
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null);
              });
            },
            child: RepaintBoundary(
                key: globalKey,
                child: Container(
                  color: selectedBackground,
                  child: Center(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: MyPainter(
                        pointsList: points,
                      ),
                    ),
                  ),
                )),
          ),
        ),
        floatingActionButton: AnimatedFloatingActionButton(
          fabButtons: fabOption(),
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.cyan,
          animatedIconData: AnimatedIcons.menu_close,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter({this.pointsList});

  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));

        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

class TouchPoints {
  Paint paint;
  Offset points;
  TouchPoints({this.points, this.paint});
}
