import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_radar/pages/exhibits/detail_page.dart';
import 'package:flutter_radar/pages/exhibits/exhibitonDetails_page.dart';
import 'package:flutter_radar/pages/exhibits/exhibitonRecommd_page.dart';
import 'package:flutter_radar/pages/exhibits/exhibits_page.dart';
import 'package:flutter_radar/pages/index_page.dart';
import 'package:flutter_radar/pages/login/login_page.dart';
import 'package:flutter_radar/pages/manage/history_page.dart';
import 'package:flutter_radar/pages/manage/host_page.dart';
import 'package:flutter_radar/pages/setting/aboutUs_page.dart';
import 'package:flutter_radar/pages/setting/servers_page.dart';
import 'package:flutter_radar/pages/setting/setPush_page.dart';
import 'package:flutter_radar/pages/manage/setHost_page.dart';


// 进入首页 handler
Handler indexPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String,List<String>> params) {
    int exhibitionId = int.parse(params['id'].first);
    return IndexPage(exhibitionId);
  }
);


// 进入展品列表 handler
Handler exhibitsPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    int exhibitionId = int.parse(params['id'].first);
    return ExhibitsPage(exhibitionId);
  }
);

// 进入 展馆、展品介绍 handler
Handler detailsPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return DetailsPage();
  }
);


// 进入登陆 handler
Handler loginPageHandler = Handler(
  handlerFunc: (BuildContext context , Map<String, List<String>> params) {
    
    return LoginPage();
  }
);


// 进入短信推送设置 handler
Handler setPushPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return SetPushPage();
  }
);

// 进入关于我们 handler
Handler aboutUsPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return AbuoutUsPage();
  }
);

//进入报警记录 handler
Handler historyPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return HistoryPage();
  }
);


//进入 报警展馆详情
Handler exhibitionDetailsPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    int exhibitionId = int.parse(params['id'] == null?'1':params['id'].first);
    
    return ExhibitionDetailsPage(exhibitionId);
  }
);

//进入新展馆详情页面
Handler exhibitionRecommdPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    int exhibitionId = int.parse(params['id'] == null?'1':params['id'].first);
    return ExhibitionRecommdPage(exhibitionId);
  }
);


//进入 临展主机管理页面
Handler hostPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return HostPage();
  }
);


//进入 临展主机参数页面
Handler setHostPageHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params){
    int hostId = int.parse(params['id'] == null?'1':params['id'].first);
    return SetHostPage(hostId);
  }
);

//进入 服务器状态页面
Handler checkServersHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ServersPage();
  }
);