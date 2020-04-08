

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_radar/model/servers_model.dart';
import 'package:flutter_radar/service/service_method.dart';

class ServersProvide with ChangeNotifier {

  ServersModel serversModel;

  getServersStatusToProvide() async {

    await getServersStatus().then((val){
      var responseData = json.decode(val.toString());
      serversModel = ServersModel.fromJson(responseData);
      notifyListeners();
    });

  }

}