// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/7
// Time  : 15:56
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_radar/pages/pin/pin.dart';


class MapView extends StatefulWidget {
  /// 地图
//  final ui.Image map;
  final ImageProvider map;

  /// 地图上的Pin
  final PinList pins;

  /// 6. 回调方法
  /// [pinId]: 被点击的pin的Id
  /// [index]: pin在Widget中的的索引用于通过'pins[index]'来获取Pin实例
  /// [position]: 点击事件发生的坐标, 可以提供给浮动窗口构造函数使用
  final void Function(Pin p, Offset position) onSelected;

  /// 两个Pin的图片
  final ImageProvider redPin;
  final ImageProvider bluePin;

  MapView(this.map, this.pins, this.onSelected, this.redPin, this.bluePin);

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  double _scale;
  Offset _offset;
  Size _iMapSize;
  Size _iWindowsSize;
  double _iScale;
  Offset _iOffset;

  ui.Offset _$focalPoint;
  ui.Offset _$offset;
  double _$scale;

  ui.Image _map;
  ui.Image _redPin;
  ui.Image _bluePin;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _loadPinImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _loadPinImage();
    super.reassemble();
  }

  void _loadPinImage() {
    widget.map
        .resolve(createLocalImageConfiguration(context))
        .addListener(ImageStreamListener((map, isSync) {
      setState(() {
        _map = map.image;
      });
      _centerAndScaleMap();
    }));
    widget.redPin
        .resolve(createLocalImageConfiguration(context))
        .addListener(ImageStreamListener((red, isSync) {
      setState(() {
        _redPin = red.image;
      });
    }));
    widget.bluePin
        .resolve(createLocalImageConfiguration(context))
        .addListener(ImageStreamListener((blue, isSync) {
      setState(() {
        _bluePin = blue.image;
      });
    }));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: CustomPaint(
            child: Container(color: Colors.red),
            foregroundPainter: MapPinPainter(
              _map,
              widget.pins,
              _scale,
              _offset,
              _redPin,
              _bluePin,
            )),
        onTapUp: (TapUpDetails d) {
          ///6. 点击事件识别
          final tap = d.localPosition;
          final p = widget.pins.clickedPin(_tapConvert(tap));
          widget.onSelected(p, tap);
        },
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
      );

  /// 点击坐标转屏幕坐标
  Offset _tapConvert(Offset tapOffset) => (tapOffset - _offset) / _scale;

  void _onScaleStart(ScaleStartDetails d) {
    _$focalPoint = d.focalPoint;
    _$offset = _offset;
    _$scale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    double newScale = _$scale * d.scale;
    // 限制view不能缩放到更小
    if (newScale < _iScale) return;
    final Offset normalizedOffset = (_$focalPoint - _$offset) / _$scale;
    final Offset newOffset = d.focalPoint - normalizedOffset * newScale;
    final Size nMapSize = _iMapSize * newScale;
    // 限制map不能移出屏幕
    if (newOffset.dx > _iWindowsSize.width * 0.9 ||
        newOffset.dx + nMapSize.width * 0.9 < 0 ||
        newOffset.dy + nMapSize.height * 0.9 < 0 ||
        // newOffset.dy > _iWindowsSize.height * 0.85) 
        newOffset.dy > 200 * 0.85) 
        return;
    print(
        '_MapViewState._onScaleUpdate #$_iOffset> $newOffset] ${_iMapSize * newScale} $_iWindowsSize');
    setState(() {
      _scale = newScale;
      _offset = newOffset;
    });
  }

  /// 图像缩放居中
  void _centerAndScaleMap() {
    _iMapSize = Size(_map.width.toDouble(), _map.height.toDouble());
    _iWindowsSize = MediaQueryData.fromWindow(ui.window).size;
    _iScale = math.min(_iWindowsSize.width / _iMapSize.width,
        _iWindowsSize.height / _iMapSize.height);
    // _iOffset = (_iWindowsSize - _iMapSize * _iScale as Offset) / 2.0;
    var t = (_iWindowsSize - _iMapSize * _iScale as Offset);
    _iOffset = Offset(t.dx/2,0);

    _scale = _iScale;
    _offset = _iOffset;
  }
}

///
/// 绘制地图与图钉
///
/// [uiMap] 地图
/// [pins] 图钉列表
/// [scale] 缩放倍数
/// [offset] 地图偏移量
/// [redPin] 红色图钉图片
/// [bluePin] 蓝色图钉图片
/// [pinWidth] 图钉图片宽度
/// [pinHeight] 图钉图片高度
/// [_focusPinIndex] 上一个被选中的图钉在 [pins]中的索引号
class MapPinPainter extends CustomPainter {
  final ui.Image uiMap;
  final PinList pins;
  final double scale;
  final Offset offset;
  final ui.Image redPin;
  final ui.Image bluePin;
  final double pinWidth;
  final double pinHeight;

  MapPinPainter(
    this.uiMap,
    this.pins,
    this.scale,
    this.offset,
    this.redPin,
    this.bluePin,
  )   : pinWidth = redPin?.width?.toDouble(),
        pinHeight = redPin?.height?.toDouble();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (uiMap == null) return;
    final paint = Paint();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    canvas.drawImage(uiMap, Offset.zero, paint);
    for (var p in pins.list) {
      p.touch =
          (p.location.translate(-pinWidth / 2 / scale, -pinHeight / scale) &
              (Size(pinWidth, pinHeight) / scale));
      canvas.saveLayer(p.touch, paint);
      canvas.scale(1 / scale);
      var nX = -p.location.dx + p.location.dx * scale;
      var nY = -p.location.dy + p.location.dy * scale;
      canvas.translate(nX, nY);
      canvas.drawImage(pins.isFocus(p) ? redPin : bluePin,
          p.location.translate(-pinWidth / 2, -pinHeight), paint);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MapPinPainter o) =>
      o.uiMap != uiMap || o.offset != offset || pins.curFocus != pins.preFocus;
}
