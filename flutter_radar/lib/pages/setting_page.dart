import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/routers/application.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: setting_backColor
      ),
      child: Column(
        children: <Widget>[
          // SettingTitle(),
          SettingSubTitle(),
          CircleView(),
          SettingListView()
        ],
      ),
    );
  }
}

// setting页面主标题
class SettingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 108),
      child: Text(
        setting_title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
          color: base_titleColor
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// setting页面副标题
class SettingSubTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(106)),
      child: Text(
        base_title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
          color: base_titleColor
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// setting ListView 圆角图
class CircleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      height: ScreenUtil().setHeight(88),
      width: ScreenUtil().setWidth(app_width),
      child: Image(
        image: AssetImage("images/yuanjiao.png"),
        fit: BoxFit.fill,
      ),
    );
  }
}

// setting ListView
class SettingListView extends StatelessWidget {

  final rowTitles = ['设置','关于我们'];
  final rowImages = ['images/xiugaimima.png','images/guanyuwomen.png'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          children: rowTitles.asMap().keys.map((f)=>
            InkWell(
              onTap: () async {
                switch (rowTitles[f]) {
                  case '设置':
                    SharedPreferences prefs = await SharedPreferences.getInstance(); 
                    String phoneNumber = prefs.getString('userName');
                    if (phoneNumber != null) {
                      Application.router.navigateTo(context, "/setPush");
                    } else {
                      Fluttertoast.showToast(
                        msg: '您尚未登陆账号，请先登录！',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                    }
                    
                    break;
                  case '关于我们':
                    Application.router.navigateTo(context, "/aboutus");
                    break;
                  default:
                }
              },
              child: Container(
                // padding: EdgeInsets.all(10),
                width: ScreenUtil().setWidth(app_width),
                height: ScreenUtil().setHeight(160),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 0.5 , color: Colors.black12)
                  )
                ),
                child: Row(
                  children: <Widget>[
                    new Expanded(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            child: Image(
                              image: AssetImage(rowImages[f]),
                              width: ScreenUtil().setWidth(44),
                              height: ScreenUtil().setHeight(44),
                              fit: BoxFit.contain,
                            ),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40),right: ScreenUtil().setWidth(25)),
                          ),
                          
                          Text(
                            rowTitles[f],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(34),
                              color: base_titleColor
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10,top: 3),
                      child: Image(
                        image: AssetImage("images/jinru.png"),
                        fit: BoxFit.fill,
                        height: ScreenUtil().setHeight(60),
                        width: ScreenUtil().setWidth(34),
                      ),
                    )
                  ],
                ),
              ),
            )
          ).toList(),
        )
      ],
    );
  }
}