import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/config/service_url.dart';
import 'package:flutter_radar/service/service_method.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetPushPage extends StatelessWidget {

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
        title: Text('推送设置'),
      ),

      body: SetPushList(),
    );
  }
}


class SetPushList extends StatefulWidget {

  @override
  _SetPushListState createState() => _SetPushListState();
}

class _SetPushListState extends State<SetPushList> {

  // SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences; 

  bool _value ;
  bool _pushValue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPushState();
  }


  void _checkPushState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    String phoneNumber = prefs.getString('userName');
    getUserPushState({'username':phoneNumber}).then((val){
        var responseData = json.decode(val.toString());
        setState(() {
          if (responseData['data']['phoneOpen'] == 0) {
          _value =false;
        } else _value =true;

        if (responseData['data']['jpushOpen'].toString().length > 0) {
          _pushValue = true;
        } else if (responseData['data']['jpushOpen'].toString() != prefs.get('jpushId')) {
          _pushValue = false;

        } else {
          _pushValue = false;
        }
        });
      });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _switchInkWell(context,'短信'),
        _switchInkWell(context,'推送通知')
      ],
    );
  }

  Widget _switchInkWell(BuildContext context, String title) {

    return InkWell(

      child: Container(
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

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(50)),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(34),
                    color: base_titleColor
                  ),
                  textAlign: TextAlign.left,
                ),
              )
            ),

            Switch(
              value: title == '短信'? _value == null? false: _value : _pushValue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (newValue) {
                setState(() {
                  switch (title) {
                    case '短信':
                      _value = newValue;
                      _setPhoneStatus(_value);
                      break;
                    case '推送通知':
                      _pushValue = newValue;
                      _setJpushStatus(_pushValue);
                      break;
                    default:
                  }
                });
              }
            ),
          ],
        ),
      ),
    );
  }

  void _setJpushStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    String phoneNumber = prefs.get('userName');
    String jpushid = prefs.getString('jpushId');
    var respone = await Dio().post(servicePath['setJpush'],queryParameters:{'username':phoneNumber,'jpushid': value?jpushid:''});
    var responseData = json.decode(respone.toString());
    if (responseData['status'] ==1) {
      Fluttertoast.showToast(
          msg: value?'推送功能已开启':'推送功能已关闭',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
      );
      
    }
  }

  void _setPhoneStatus(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    String phoneNumber = prefs.getString('userName');
    if (phoneNumber != null) {
      var respone = await Dio().post(servicePath['smsPage'],queryParameters:{'phoneNumber':phoneNumber,'type': value?'start':'disable'});
      var responseData = json.decode(respone.toString());
      if (responseData['status'] ==1) {
        Fluttertoast.showToast(
          msg: value?'短信接收功能已开启':'短信接收功能已关闭',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } else {
        setState(() {
          _value = false;
        });

        Fluttertoast.showToast(
          msg: '您尚未拥有接收短信权限，请联系管理员！',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
      prefs.setBool('phoneNumberPush', value);
    } else {
        Fluttertoast.showToast(
          msg: '您尚未登陆账号，请先登录！',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
    }
  }

}