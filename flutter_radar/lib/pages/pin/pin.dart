
// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/6
// Time  : 12:24

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_radar/model/exhibits_model.dart';

class PinList {
  Pin _curFocus;
  Pin _preFocus;
  List<Pin> _list;

  PinList({List<Pin> init}) : _list = init ?? [];

  set add(Pin p) => _list.add(p);

  set addAll(List<Pin> plist) => _list.addAll(plist);

  set curFocus(Pin f) {
    // _preFocus = _preFocus;
    _preFocus = _curFocus;
    _curFocus = f;
  }

  Pin get curFocus => _curFocus;

  Pin get preFocus => _preFocus;

  List<Pin> get list => _list;

  Pin clickedPin(Offset tap) {
    var i = _list.lastIndexWhere((p) => p.touch.contains(tap));
    if (i == -1) return null;
    return _list[i];
  }

  isFocus(Pin p) => _curFocus == p;
}

/// 大头针
class Pin extends Exhibits{ //修改 继承exhibits  能获取到网络上的xy坐标并输入给 location属性
  /// 标签
  final int pinId;

  /// 相对于地图中心的点位
  final Offset location;

  /// 触摸位置
  Rect touch;

  Pin(this.pinId, this.location);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pin &&
          runtimeType == other.runtimeType &&
          pinId == other.pinId &&
          location == other.location;

  @override
  int get hashCode => pinId.hashCode ^ location.hashCode;

  @override
  String toString() => 'Pin{pinId: $pinId, location: $location, touch: $touch}';
}
