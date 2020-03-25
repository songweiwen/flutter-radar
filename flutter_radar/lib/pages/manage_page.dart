
import 'package:flutter/material.dart';
import 'package:flutter_radar/routers/application.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ManagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            
            Padding(
              padding: EdgeInsets.only(top: 100),
              child: Center(
                child: MaterialButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance(); 
                    String phoneNumber = prefs.getString('userName');
                    if (phoneNumber != null) {
                      Application.router.navigateTo(context, "/hostpage");
                    } else {
                      Fluttertoast.showToast(
                        msg: '您尚未登陆账号，请先登录！',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  },
                  child: Text('设备管理'),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 100),
              child: Center(
                child: MaterialButton(
                  onPressed: (){
                    Application.router.navigateTo(context, "/historypage");
                  },
                  child: Text('报警记录查询'),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}