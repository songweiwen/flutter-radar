import 'package:flutter/material.dart';

class ExhibitsModel {
  int status;
  String message;
  List<Exhibits> data;
  String timestamp;

  ExhibitsModel({this.status, this.message, this.data, this.timestamp});

  ExhibitsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Exhibits>();
      json['data'].forEach((v) {
        data.add(new Exhibits.fromJson(v));
      });
    }
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Exhibits {
  int rfidId;
  int showcaseId;
  String exhibitsId;
  int exhibitionId;
  String exhibitsName;
  String exhibitsImg;
  double mobileLeft;
  double mobileTop;
  double masterLeft;
  double masterTop;
  String exhibitsRecommend;

  //为了迎合 地图大头针变色新增的属性
  bool isRed;
  String img;
  Offset offset;

  //
  String warningType;
  String timeStr;

  bool isJpush = false;

  Exhibits(
      {this.rfidId,
      this.showcaseId,
      this.exhibitsId,
      this.exhibitionId,
      this.exhibitsName,
      this.exhibitsImg,
      this.mobileLeft,
      this.mobileTop,
      this.masterLeft,
      this.masterTop,
      this.exhibitsRecommend,
      //
      this.img='',
      this.isRed = true,
      this.offset,
      // this.timeStr,
      this.warningType,

      this.isJpush = false
      });

    @override
    String toString(){
      return 'Model{序号：$rfidId，是否是红色的:$isRed, img: $img, 坐标便宜: $offset}';
    }

  Exhibits.fromJson(Map<String, dynamic> json) {
    rfidId = json['rfidId'];
    showcaseId = json['showcaseId'];
    exhibitsId = json['exhibitsId'];
    exhibitionId = json['exhibitionId'];
    exhibitsName = json['exhibitsName'];
    exhibitsImg = json['exhibitsImg'];
    mobileLeft = json['mobileLeft'];
    mobileTop = json['mobileTop'];
    masterLeft = json['masterLeft'];
    masterTop = json['masterTop'];
    exhibitsRecommend = json['exhibitsRecommend'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rfidId'] = this.rfidId;
    data['showcaseId'] = this.showcaseId;
    data['exhibitsId'] = this.exhibitsId;
    data['exhibitionId'] = this.exhibitionId;
    data['exhibitsName'] = this.exhibitsName;
    data['exhibitsImg'] = this.exhibitsImg;
    data['mobileLeft'] = this.mobileLeft;
    data['mobileTop'] = this.mobileTop;
    data['masterLeft'] = this.masterLeft;
    data['masterTop'] = this.masterTop;
    data['exhibitsRecommend'] = this.exhibitsRecommend;
    return data;
  }
}