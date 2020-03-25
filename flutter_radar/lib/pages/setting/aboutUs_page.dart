import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AbuoutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app_title + back
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('关于我们'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
                child: Center(
                  child: Text(
                    '北京达因瑞康电气设备有限公司', 
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                child: Center(
                  child: Text(
                    '程序版本号:' + app_version, 
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(100), right: ScreenUtil().setWidth(20),left: ScreenUtil().setWidth(20)),
                child: Text(mianzeshengming_title),
              )
            ],
          ),
        )
      ),
    );
  }
}