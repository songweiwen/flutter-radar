

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_radar/model/host_model.dart';
import 'package:flutter_radar/service/service_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HostListProvide with ChangeNotifier {

  HostModel hostModel = new HostModel();
  List<Host> hostList = [];
  List<Host> hostListByExhbition = [];

  getHostList() async {
    
    SharedPreferences.getInstance().then((val) async {
      String phoneNumber = val.getString('userName');
      Map<String, dynamic> d = {'username':phoneNumber};
      await getHost(data: d).then((val){
        var responseData = json.decode(val.toString());
        hostModel = HostModel.fromJson(responseData);
        hostList = [];
        if (hostModel.data.length >0) {
          hostModel.data.forEach((item) {
            if ((item.hostElectric == '交流故障')|| (item.hostState == '故障')) {
              item.isWarning = true;
            } else item.isWarning =false;
            hostList.add(item);
          });
        } else {
          hostList=[];
        }
        notifyListeners();
      });
    });


  }
  
  // 根据socket收到的 host 进行数据改写 
  changeHostList(Host h) {
    for (Host item in hostList) {
      if (item.hostId == h.hostId) {
        item.hostState = h.hostState;
        item.hostElectric = h.hostElectric;
        item.updateTime = h.updateTime;
        item.isWarning = h.isWarning;
      }
    }

    notifyListeners();
  }


  getHostStateById(int hostId) async {

    // await ().then(onValue)

    await getHostState({'hostId':hostId}).then((val){
      var responseData = json.decode(val.toString());
      HostStateModel hModel = HostStateModel.fromJson(responseData);
      Host h = hModel.data;
      if ((h.hostElectric == '交流故障')|| (h.hostState == '故障')) {
        h.isWarning = true;
      } else h.isWarning =false;
      changeHostList(h);
    });
  }

  // 根据假如来的场馆来筛选大头针
  createPinsWithHostByExhibition(int exhibitionId) {
    
    String rec = exhibitionId == 8? '紫檀宫西厅':exhibitionId == 9? '紫檀宫中厅':'紫檀宫东厅';
    hostListByExhbition.clear();

    if (hostList.length != 0) {
      
      for (Host h in hostList) {
        if (h.hostRecommend == rec) {
          hostListByExhbition.add(h);
        }
      }
      notifyListeners();
    } 

  }


  // 传入参数 并写入当前host缓存
  
  
}






class HostStateModel {
  int status;
  String message;
  Host data;
  String timestamp;

  HostStateModel({this.status, this.message, this.data, this.timestamp});

  HostStateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Host.fromJson(json['data']) : null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}