

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/model/main_model.dart';
import 'package:flutter_radar/model/warning_model.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/service/service_method.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPageProvide with ChangeNotifier {

  MainModel mainModel = new MainModel();
  List<String> swiperDataList = [];
  List<Exhibition> exhibitionList = [];
  Exhibition exhibition = new Exhibition();
  List<Exhibition> areaNameList = [];
  ExhibitsModel exhibitsModel = new ExhibitsModel();

  List<Exhibits> allExhibitsList = [];

  List<Exhibits> allExhibitsByExhbition = [];

  WarningModel warningModel = new WarningModel();
  List<Warning> warningList = [];

  // 从网络中获取 展馆列表 并整理展馆地区归类给轮播图
  getMainPageList() async {
    
    await getMainPageContent().then((val){
      var responseData = json.decode(val.toString());
      mainModel = MainModel.fromJson(responseData);
      if (exhibitionList.length == mainModel.data.length) {
        
      } else {
        swiperDataList = [];
        exhibitionList = [];
        // 筛选数据
        for (Exhibition element in mainModel.data) {
          if (!swiperDataList.contains(element.areaName)) {
            swiperDataList.add(element.areaName);
          } 
          exhibitionList.add(element);
        }
        notifyListeners();
      }
    });
  }


  // 获取最近一小时内的报警记录。
  getWarningListByHour(BuildContext context) async {
    
   await getWarningListByHours().then((val){
      var responseData = json.decode(val.toString());
      warningModel = WarningModel.fromJson(responseData);
      if (warningList.length ==warningModel.data.length) {
        // warningList=[];
      } else {
        warningList=[];
        if (warningModel.data.length >0) {
          
          for(int i=warningModel.data.length-1;i>=0;i--){
            /////////////////////
            warningList.add(warningModel.data[i]);
          }

        } else {
          warningList=[];
        }
      }
      Provide.value<SocketNotifyProvide>(context).setWarningLIstByHour(context, warningList);
    });
  }

  //根据地区名字找到第一个对应的展馆并获取
  getFirstExhibitionByString(String areaName) {
    if (exhibitionList != null) {
      exhibition = new Exhibition();//重置数据
      for (Exhibition item in exhibitionList) {
        if (item.areaName == areaName) { //遍历地区所在的展馆。 只要找到第一个  立刻返回
          exhibition = item;
          continue;
        }
      }
    }

    getExhibitionsByExhibitionAreaName(exhibition.exhibitionAreaName);
    
    // notifyListeners();
  }

  // 根据大展馆的名字整理出大展馆列表
  getExhibitionsByExhibitionAreaName(String name) {
    areaNameList = [];
    if(exhibitionList != null) {
      for (Exhibition item in exhibitionList) {
        if (item.exhibitionAreaName == name) {
          areaNameList.add(item);
        }
      }
    }
    notifyListeners();
  }

  //根据地区id 找到对应的展馆并获取
  getExhibitionInfoById(int exhibitionId) {
    if (exhibitionList != null) {
      exhibition = new Exhibition();
      for (Exhibition item in exhibitionList) {
        if (item.exhibitionId == exhibitionId) {
          exhibition = item;
          continue;
        }
      }
    }
    notifyListeners();
  }


    //
  getExhibitsListByExhibition(int exhibitionId) {
    allExhibitsByExhbition=[];
    for (Exhibits item in allExhibitsList) {
      if (item.exhibitionId == exhibitionId) {
        allExhibitsByExhbition.add(item);
      }
    }
    notifyListeners();
  }

  // 把当前展馆的所有rifd拿到
  getAllRFIDByExhibition(Map<String, dynamic> data) async{
    
   SharedPreferences.getInstance().then((val) async {
      String phoneNumber = val.getString('userName');
      Map<String, dynamic> d = {'exhibitsArea':data['exhibitsArea'],'username':phoneNumber};
      await getRFIDByExhibition(data: d).then((val){
        if(val != null) {
          var responseData = json.decode(val.toString());
          exhibitsModel = ExhibitsModel.fromJson(responseData);
          if (allExhibitsList.length == exhibitsModel.data.length) {
            
          } else {
            allExhibitsList = [];
            // 筛选数据
            for (Exhibits element in exhibitsModel.data) {

                allExhibitsList.add(element);
            }
            notifyListeners();
          }
        }
      });
    });

  }
}
