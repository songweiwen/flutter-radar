
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_radar/config/android_back_desktop.dart';
import 'package:flutter_radar/pages/main_page.dart';
import 'package:flutter_radar/provide/currentIndex.dart';
import 'package:flutter_radar/provide/exhibitsList.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_radar/provide/servers_provide.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/provide/warningManage.dart';
import 'package:flutter_radar/routers/application.dart';
import 'package:flutter_radar/routers/routers.dart';
import 'package:provide/provide.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized(); 

  //状态管理
  var mainPageProvide = MainPageProvide();
  var currentIndexProvide = CurrentIndexProvide();
  var warningManageProvide = WarningManageProvide();
  var exhibitsListProvide = ExhibitsListProvide();
  var socketNotifyProvide = SocketNotifyProvide();
  var hostPageProvide = HostListProvide();
  var serversPageProvide = ServersProvide();
  var providers = Providers();
  providers
  ..provide(Provider<ServersProvide>.value(serversPageProvide))
  ..provide(Provider<HostListProvide>.value(hostPageProvide))
  ..provide(Provider<SocketNotifyProvide>.value(socketNotifyProvide))
  ..provide(Provider<ExhibitsListProvide>.value(exhibitsListProvide))
  ..provide(Provider<WarningManageProvide>.value(warningManageProvide))
  ..provide(Provider<CurrentIndexProvide>.value(currentIndexProvide))
  ..provide(Provider<MainPageProvide>.value(mainPageProvide));
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      //状态管理全局注册
      runApp(ProviderNode(child: MyApp(),providers:providers));
  });
}

class MyApp extends StatelessWidget {

  // 中文配置
  List<Locale> an = [
    const Locale('zh', 'CH'),
    const Locale('en', 'US'),
  ];
  List<Locale> ios = [
    const Locale('en', 'US'),
    const Locale('zh', 'CH'),
  ];
     
  @override
  Widget build(BuildContext context) {

    //  配置路由 静态化文件
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
    
    return BotToastInit(child: ConnectivityAppWrapper(
      app: MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        title:'外借临展文物防护系统',
        onGenerateRoute: Application.router.generator, // 配置路由
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor:Colors.white,
        ),
        home: WillPopScope(
          onWillPop: () async {
            AndroidBackTop.backDeskTop();
            return false;
          },
          child: MainPage(),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: Platform.isIOS ? ios : an,
      ),
    ),);
  }
}
