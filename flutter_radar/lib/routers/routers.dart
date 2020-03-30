import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/routers/router_handler.dart';

import 'router_handler.dart';

class Routes {
  static String root = '/';
  static String indexPage = '/index';
  static String exhibitsPage = '/exhibits';
  static String detailsPage = '/details';
  static String loginPage = '/login';
  static String setPushPage = '/setPush';
  static String aboutUsPage = '/aboutus';
  static String historyPage = '/historypage';
  static String exhibitionDetailsPage = '/exhibitiondetailspage';
  static String exhibitionRecommdPage = '/exhibitionrecommdpage';
  static String hostPage = '/hostpage';
  static String sethostPage = '/sethostpage';
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        print('');
      }
    );

    router.define(indexPage,handler:indexPageHandler);
    router.define(exhibitsPage,handler:exhibitsPageHandler);
    router.define(detailsPage,handler:detailsPageHandler);
    router.define(loginPage,handler:loginPageHandler);
    router.define(setPushPage,handler:setPushPageHandler);
    router.define(aboutUsPage,handler:aboutUsPageHandler);
    router.define(historyPage,handler:historyPageHandler);
    router.define(exhibitionDetailsPage,handler: exhibitionDetailsPageHandler);
    router.define(exhibitionRecommdPage,handler: exhibitionRecommdPageHandler);
    router.define(hostPage,handler:hostPageHandler);
    router.define(sethostPage, handler: setHostPageHandler);
  }
}