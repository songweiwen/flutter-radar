import 'dart:async';
import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/config/service_url.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/service/service_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //获取Key用来获取Form表单组件
  GlobalKey<FormState> loginKey = new GlobalKey<FormState>();
  String userName;
  String password;
  bool isShowPassWord = false;

  var countdownTime = 0;
  Timer _timer;

  //倒计时方法
  startCountdown() {
    countdownTime = 60;
    final call = (timer) {
      setState(() {
        if (countdownTime < 1) {
          _timer.cancel();
        } else {
          countdownTime -= 1;
        }
      });
    };
    _timer = Timer.periodic(Duration(seconds:1), call);
  }

  void login() async{
    BotToast.showLoading(duration: Duration(seconds: 10));
    //读取当前的Form状态
    var loginForm = loginKey.currentState;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jpushId = '';
    if (prefs.get('jpushId') != null) {
      jpushId = prefs.get('jpushId');
    }
    //验证Form表单
    if(loginForm.validate()){
      loginForm.save();
      print('userName: ' + userName + ' password: ' + password);
      var response = await Dio().post(servicePath['loginPage'],queryParameters:{'username':userName,'password':password,'jpushId':jpushId});
      var responseData = json.decode(response.toString());
      BotToast.closeAllLoading();
      if (responseData['status'] == 1) {
        Fluttertoast.showToast(
          msg: "登录成功！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        
        // 本地持久化数据
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', userName);
        prefs.setInt('admin', responseData['data']['admin']);

        // 登陆成功后需要对socket进行连接处理
        Provide.value<SocketNotifyProvide>(context).setSocketStatus(3, '',null);

        Navigator.pop(context);
        
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }

  void showPassWord() {
    setState(() {
      isShowPassWord = !isShowPassWord;
    });
  }

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
        title: Text('登录'),
      ),

      body: SingleChildScrollView(

        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(16.0),
              child: new Form(
                key: loginKey,
                autovalidate: true,
                child: new Column(
                  children: <Widget>[
                    new Container(
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 240, 240, 240),
                            width: 1.0
                          )
                        )
                      ),
                      child: new TextFormField(
                        decoration: new InputDecoration(
                          labelText: '请输入手机号',
                          labelStyle: new TextStyle( fontSize: 15.0, color: Color.fromARGB(255, 93, 93, 93)),
                          border: InputBorder.none,
            
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (value) {
                          userName = value;
                        },
                        validator: (phone) {
                          
                        },
                        onFieldSubmitted: (value) {

                        },  
                      ),
                    ),
                    new Container(
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 240, 240, 240),
                            width: 1.0
                          )
                        )
                      ),
                      child: new TextFormField(
                        decoration:  new InputDecoration(
                          labelText: '请输入6位验证码',
                          labelStyle: new TextStyle( fontSize: 15.0, color: Color.fromARGB(255, 93, 93, 93)),
                          border: InputBorder.none,
                          suffixIcon: new IconButton(
                            icon: new Icon(
                              isShowPassWord ? Icons.visibility : Icons.visibility_off,
                              color: Color.fromARGB(255, 126, 126, 126), 
                            ),
                            onPressed: showPassWord,
                          )
                        ),
                        obscureText: !isShowPassWord,
                        onSaved: (value) {
                          password = value;
                        },
                      ),
                    ), 

                    new Container(
                      height: 45.0,
                      margin: EdgeInsets.only(top: 40.0),
                      child: new SizedBox.expand(   
                        child: new RaisedButton(
                          onPressed: (){
                            if (countdownTime == 0) {
                              // 获取验证码逻辑
                              getVerCodeByPhone();
                              
                            } else {
                                Fluttertoast.showToast(
                                  msg: '请勿重复获取验证码！',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                );
                            }
                          },
                          color: Color.fromARGB(255, 61, 203, 128),
                          child: new Text(
                            _handleCodeText(),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color.fromARGB(255, 255, 255, 255)
                            ),
                          ), 
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(45.0)),
                        ), 
                      ),  
                    ),

                    new Container(
                      height: 45.0,
                      margin: EdgeInsets.only(top: 20.0),
                      child: new SizedBox.expand(   
                        child: new RaisedButton(
                          onPressed: login,
                          color: Color.fromARGB(255, 61, 203, 128),
                          child: new Text(
                            '登录',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color.fromARGB(255, 255, 255, 255)
                            ),
                          ), 
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(45.0)),
                        ), 
                      ),  
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void getVerCodeByPhone() async{
    //读取当前的Form状态
    var loginForm = loginKey.currentState;
        //验证Form表单
    if(loginForm.validate()){
        loginForm.save();
        await getPhoneVerCode({'username':userName}).then((val){
        var responseData = json.decode(val.toString());
        if (responseData['status'] == 100) {
          Fluttertoast.showToast(
            msg: '请勿重复获取验证码！',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
        if (responseData['status'] == 0) {
          Fluttertoast.showToast(
            msg: '该账号不存在！如需使用请联系管理员！',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
        if (responseData['status'] == 200) {
          Fluttertoast.showToast(
            msg: '验证码已发送，请注意查看手机短信！',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );

          startCountdown();
        }
      });
    }

  }

  String _handleCodeText(){
    if (countdownTime > 0) {
      return '${countdownTime}s后重新获取';
    } else {
      return '获取验证码';
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}