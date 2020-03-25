
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_radar/model/warning_model.dart';
import 'package:flutter_radar/service/service_method.dart';

class WarningManageProvide with ChangeNotifier {

  // String warningString = '';
  WarningModel warningModel = new WarningModel();
  List<Warning> warningList = [];

  getWarningManageList() async {
    // warningList =[];
    await getWarningMangeContent().then((val){
      var responseData = json.decode(val.toString());
      warningModel = WarningModel.fromJson(responseData);
      if (warningList.length ==warningModel.data.length) {
        // warningList=[];
      } else {
        warningList=[];
        if (warningModel.data.length >0) {
          
          for(int i=warningModel.data.length-1;i>=0;i--){
            warningList.add(warningModel.data[i]);
          }

        } else {
          warningList=[];
        }
      }
      notifyListeners();
    });
  }


}
