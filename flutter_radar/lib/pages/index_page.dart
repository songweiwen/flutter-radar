
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/pages/exhibition_page.dart';
import 'package:flutter_radar/pages/manage/history_page.dart';
import 'package:flutter_radar/pages/manage/host_page.dart';
import 'package:flutter_radar/pages/setting_page.dart';
import 'package:flutter_radar/provide/currentIndex.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

class IndexPage extends StatelessWidget {

  // 路由传递的参数  展馆id
  final int exhibitionId;
  IndexPage(this.exhibitionId);

  // 导航tables
  final List<BottomNavigationBarItem> bottomTabs = [
    BottomNavigationBarItem(
      icon: Image(image: AssetImage("images/zhanlan.png"),
        height: ScreenUtil().setHeight(50),
        width: ScreenUtil().setWidth(50),
        fit: BoxFit.contain,
      ),
      title: Text('展览',style: TextStyle(color: Colors.black,
        fontSize: ScreenUtil().setSp(20)
      ),)
    ),
    BottomNavigationBarItem(
      icon: Image(image: AssetImage("images/baojinggguanli.png"),
        height: ScreenUtil().setHeight(50),
        width: ScreenUtil().setWidth(50),
        fit: BoxFit.contain,
      ),
      title: Text('报警管理',style: TextStyle(color: Colors.black,
        fontSize: ScreenUtil().setSp(20)
      ),)
    ),
    BottomNavigationBarItem(
      icon: Badge(
        badgeContent: Text(''),
        child: Image(image: AssetImage("images/baojinggguanli.png"),
          height: ScreenUtil().setHeight(50),
          width: ScreenUtil().setWidth(50),
          fit: BoxFit.contain,
        ),
        showBadge: false,
      ),

      title: Text('设备管理',style: TextStyle(color: Colors.black,
        fontSize: ScreenUtil().setSp(20)
      ),)
    ),
    BottomNavigationBarItem(
      icon: Image(image: AssetImage("images/shezhi.png"),
        height: ScreenUtil().setHeight(50),
        width: ScreenUtil().setWidth(50),
        fit: BoxFit.contain,
      ),
      title: Text('设置',style: TextStyle(color: Colors.black,
        fontSize: ScreenUtil().setSp(20)
      ),)
    )
  ];

  final List<Widget> tabBodies = [
    ExhibitionPage(),
    // ManagePage(),
    HistoryPage(),
    HostPage(),
    SettingPage()
  ];


  @override
  Widget build(BuildContext context) {

    return Provide<CurrentIndexProvide>(
      builder: (context,child,val){
        int currentIndex = Provide.value<CurrentIndexProvide>(context).currentIndex;
        return Scaffold(
          // app_title + back
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            // title: Text('展馆'),
          ),

          // 右侧侧边栏
          // endDrawer: Drawer(
          //   child: ListView(
          //     children: <Widget>[
          //       Text('切换展馆')
          //     ],
          //   ),
          // ),

          //底部菜单栏路由
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            items: bottomTabs,
            onTap: (index){
              Provide.value<CurrentIndexProvide>(context).changeIndex(index);
              if (index == 2) {
                Provide.value<CurrentIndexProvide>(context).changeHostBadge(false);
                Provide.value<HostListProvide>(context).getHostList();
              }
            },
          ),
          body: Stack(
            children: <Widget>[
              IndexedStack(
                index: currentIndex,
                children: tabBodies,
              ),
            ],
          )

        );
      },
    );
  }
}

