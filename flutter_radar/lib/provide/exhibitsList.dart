

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/service/service_method.dart';

class ExhibitsListProvide with ChangeNotifier {

  ExhibitsModel exhibitsModel = new ExhibitsModel();
  List<Exhibits> exhibitsList =[];
  Exhibits exhibits = new Exhibits();

  //  网络获取 文物列表
  getExhibitsList(Map<String, dynamic> data, ) async {
    exhibitsList=[];
    await getExhibtsByExhibitionId(data: data).then((val){
      var responseData = json.decode(val.toString());
      exhibitsModel = ExhibitsModel.fromJson(responseData);
      if (exhibitsList.length == exhibitsModel.data.length) {
        // exhibitsList=[];
      } else {
        if (exhibitsModel.data.length >0) {
            exhibitsModel.data.forEach((item) {
            item.offset = Offset(item.mobileLeft, item.mobileTop);
            item.img = "images/蓝灯正常.png"; // 所有的蓝灯都是正常的初始化数据
            item.isRed = false;
            exhibitsList.add(item);
          });
        } else {
          exhibitsList=[];
        }
        notifyListeners(); 
      }
      
    });
  }



    //根据文物id 获取文物详情
  getExhibitsById(String id) async {
    // 清空 exhibits model
    exhibits = new Exhibits();
    if (exhibitsList != null) {
      for (Exhibits item in exhibitsList) {
        if (item.exhibitsId == id) {
          exhibits = item;
        }
      }
    }

    notifyListeners();
  }

  // 根据报警标签  找到list对应的值并改变
  changeRFIDBySocket(List<RFIDSocketModel> rlist) {

    for (Exhibits item in exhibitsList) {
      item.offset = Offset(item.mobileLeft, item.mobileTop);
      item.img = "images/landengzhengchang.png"; // 所有的蓝灯都是正常的初始化数据
      item.isRed = false;
      for (RFIDSocketModel r in rlist) {
        if (item.rfidId == r.rfidId) {
          item.offset = Offset(item.mobileLeft, item.mobileTop);
          item.img = "images/hongdengyichang.png"; // 所有的蓝灯都是正常的初始化数据
          item.isRed = true;
          // exhibitsList.add(item);
          continue;
        }
      }
    }
    notifyListeners();  
  }

}