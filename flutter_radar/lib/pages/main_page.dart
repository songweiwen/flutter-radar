import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/config/service_url.dart';
import 'package:flutter_radar/model/host_model.dart';
import 'package:flutter_radar/model/main_model.dart';
import 'package:flutter_radar/pages/socket/socket.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/routers/application.dart';
import 'package:flutter_radar/service/service_method.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/appSetting.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  String userName = '';
  var networkManager;

  //极光推送
  final JPush jpush = new JPush();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initPlatformState();
    if (Platform.isIOS) {
      jpush.setBadge(0);
    }

    // 检查用户是否登陆过。 
    SharedPreferences.getInstance().then((val){
      if(val.getString('userName')!=null) {
        this.initSocket();
      } else {
        Fluttertoast.showToast(
          msg: "请先登陆账号以连接通讯服务器。",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    });
  }

  //极光推送
  Future<Void> initPlatformState() async {

    try {
      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("flutter收到通知: $message");

          var json;
          if (Platform.isAndroid) {
            json = jsonDecode(message['extras']['cn.jpush.android.EXTRA']);
          } else {
            // jpush.clearAllNotifications();
            if (Platform.isIOS) {
              jpush.setBadge(0);
              json = jsonDecode(message['extras']['cn.jpush.android.EXTRA']);
            }
          }

          // String content = json['content'].toString();
          if (json['content'] != null ) {
            Provide.value<SocketNotifyProvide>(context).setJpushContentCheck( json['content'].toString(), context,json['time']);
            /////严重bug/////
            // Provide.value<MainPageProvide>(context).getAllRFIDByExhibition({'exhibitsArea':'珠海紫檀宫'});
          }

          if (json['Master'] != null) {
            Host h = new Host();
            h.hostId = int.parse(json['Master']);
            h.hostElectric =  json['ect_status'] == '02' ?'交流故障':'交流正常';
            h.hostState = json['banka'] == '00' ? '正常': '故障';
            if ((h.hostElectric == '交流故障')|| (h.hostState == '故障')) {
              h.isWarning = true;
            } else h.isWarning =false;
            h.updateTime = DateTime.now().subtract(new Duration(hours: 8)).toIso8601String();
            Provide.value<HostListProvide>(context).changeHostList(h);

             Fluttertoast.showToast(
                msg: message['alert'],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 10,
                textColor: Colors.black,
                backgroundColor: Colors.red
                // textColor: "#9E9E9E",
                // textcolor: '#ffffff'
              );
          }

          // print(content);
          
          setState(() {
            // debugLable = "flutter onReceiveNotification: $message";
          });
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          print("flutter打开通知: $message");
          setState(() {
            // debugLable = "flutter onOpenNotification: $message";
          });
        },
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("flutter收到消息: $message");
          setState(() {
            // debugLable = "flutter onReceiveMessage: $message";
          });
        },
      );
    } catch(e) {
      // platformVersion = 'Failed to get platform version.';
    }

    jpush.setup(
      appKey: "bc15fb173693ad4721e72b27",
      channel: "theChannel",
      production: false,
      debug: true,
      );
    jpush.applyPushAuthority(new NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true)
    );


    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      print("flutter 获取到的注册id : $rid");
      saveJpushId(rid);
      setState(() {
        // debugLable = "flutter getRegistrationID: $rid";
      });
    });

   
    
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   // debugLable = platformVersion;
    // });
  }

// 保存极光推送 rid到本地
  void saveJpushId(String rid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString('jpushId', rid);
  }

  //定时器同步锁
  bool timerlock = true;


    // 重新编写 socket模块
  void initSocket() async{
    networkManager  = null;
    networkManager = SocketNetWorkManager(socketUrl, 5230,context);
    await networkManager.init();
    if (networkManager !=null) {
      //发送登陆请求
      networkManager.sendLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置自动布局 
    ScreenUtil.instance = ScreenUtil(width: app_width, height: app_height)..init(context);
    Timer timer;

    BotToast.showLoading();

    return Stack(
      children: <Widget>[
        //布局页面主体
        Scaffold(
          body: FutureBuilder(
            future: _getMainPageInfo(context),
            builder: (context, snapshot){
              if (snapshot.hasData != null) {
                List<String> swiperDataList = Provide.value<MainPageProvide>(context).swiperDataList;
                if (swiperDataList.length != 0) {
                  BotToast.closeAllLoading();
                  return Container(
                    width: ScreenUtil().setWidth(app_width),
                    // 底板 青花瓷底图
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/bg1.jpg"),
                        fit: BoxFit.fill,
                      )
                    ),

                    // 内容组件
                    child: Stack(
                      children: <Widget>[
                        
                        Positioned(right: 0, left: 0, top: 0, bottom: 0,
                          child: Column(
                            children: <Widget>[
                              //app 标题
                              AppTitle(),
                              //app 宫标
                              Padding(
                                child: Image(
                                  image: AssetImage('images/gongbiao.png'),
                                  fit:BoxFit.fill,
                                  height: ScreenUtil().setHeight(455),
                                  width: ScreenUtil().setWidth(356),
                                ),
                                padding: new EdgeInsets.only(top: ScreenUtil().setHeight(160)),
                              ),
                              //轮播图组件
                              SwiperDiy(swiperDataList: swiperDataList,userName: userName,),
                              ],
                          ),
                        ),

                        //登陆状态按钮
                        Positioned(left: 10, top: 35,
                          width: ScreenUtil().setWidth(500),
                          height: ScreenUtil().setHeight(60),
                          child: FutureBuilder(
                            future: _checkUserLoginStatus(context),
                            builder: (context,snapshot){
                                if (userName != '0') {

                                  return Row(
                                    children: <Widget>[
                                      // SocketManager(context),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text('欢迎：${userName}'),
                                      ),
                                      MaterialButton(
                                        color: Colors.red,
                                        child: Text(
                                          '注销',
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(20),
                                            color: Colors.white
                                          ),
                                        ),
                                        minWidth: ScreenUtil().setWidth(80),
                                        onPressed: (){
                                          showDialog<Null>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                  return new AlertDialog(
                                                      title: new Text('提示'),
                                                      content: new SingleChildScrollView(
                                                          child: new ListBody(
                                                              children: <Widget>[
                                                                  new Text('是否确认注销账号？'),
                                                                  new Text('注销账号将无法使用本App的基本功能。'),
                                                              ],
                                                          ),
                                                      ),
                                                      actions: <Widget>[
                                                          new FlatButton(
                                                              child: new Text(
                                                                '确定',
                                                                style: TextStyle(
                                                                  color: Colors.red
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                //发送关闭socket处理
                                                                Provide.value<SocketNotifyProvide>(context).setSocketStatus(99,"",null);
                                                                  // 删除所有本地化配置
                                                                  _clear();
                                                                  // 退出sokcet服务器
                                                                  // 退出极光推送
                                                                  Navigator.of(context).pop();
                                                              },
                                                          ),
                                                          new FlatButton(
                                                              child: new Text('取消'),
                                                              onPressed: () {
                                                                  Navigator.of(context).pop();
                                                              },
                                                          ),
                                                      ],
                                                  );
                                              },
                                          ).then((val) {
                                              print(val);
                                          });
                                        },
                                      )
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: <Widget>[
                                      MaterialButton(
                                        color: Colors.lightBlue,
                                        child: Text(
                                          '登录',
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(20),
                                            color: Colors.white
                                          ),
                                        ),
                                        minWidth: ScreenUtil().setWidth(80),
                                        onPressed: (){
                                          Application.router.navigateTo(context, "/login");
                                        },
                                      ),
                                    ],
                                  );
                                }
                            },
                          )
                        )
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Text('加载中'),
                  );
                }

              } else {
                return Center(
                  child: Text('加载中'),
                );
              }
            },
          )
        ),

        //socket主体
        Container(
          child:Provide<SocketNotifyProvide>(
            builder: (context,child,val){
              int socketStatus = Provide.value<SocketNotifyProvide>(context).status;
              switch (socketStatus) {
                case 1:
                  timer!=null? timer.cancel():'';
                  if (timerlock) {
                        //每秒发一次心跳请求
                    Timer.periodic(Duration(seconds: 30), (t){
                      networkManager.sendHeart();
                      //给心跳增加数据
                      Provide.value<SocketNotifyProvide>(context).checkHeartBest();
                      new DateTime.now().millisecondsSinceEpoch;
                    });
                    timerlock=false;
                  }
                  break;
                case 3:
                
                  if (Provide.value<SocketNotifyProvide>(context).server_HeartBest >= 3) {
                    //重新建立连接之前。需要抛弃上一个对象
                    // networkManager.socket = null;
                    this.initSocket();
                    networkManager.sendLogin();
                  } else {
                    Provide.value<SocketNotifyProvide>(context).addHeartBest();
                  } 
                  break;
                case 9:
                  print('读取参数正在执行中！');
                  networkManager.sendReadHost(Provide.value<SocketNotifyProvide>(context).sendBody);
                  break;

                case 10:
                  print('设置参数正在执行中！'); 
                  networkManager.sendSetHost(Provide.value<SocketNotifyProvide>(context).sendBody,Provide.value<SocketNotifyProvide>(context).dataObject);
                  break;
                // 退出登陆之后要将socket挂起
                case 99:
                  print('用户退出登陆');
                  if (networkManager != null) {
                    networkManager.doneHandler();
                  }
                  break;
                default:
              }

              //每次执行完一部分代码之后给 socketstatus指令设置为0   以保证程序不会重复执行该段指令
              Provide.value<SocketNotifyProvide>(context).setSocketClear();

              return Container();
            },
          ),
        )

      ],
    );
  }

  void _clear() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await exitJpush({'username':prefs.get('userName')}).then((val){
      var responseData = json.decode(val.toString());
      if (responseData['status'] == 1) {
        // prefs.clear(); //全部清空
        prefs.remove('userName');
        setState((){
          userName = '';
        });
      }
    });

  }

  Future<String> _getMainPageInfo(BuildContext context) async{
    await Provide.value<MainPageProvide>(context).getMainPageList();
    return 'end';
  }

  Future<String> _checkUserLoginStatus(BuildContext context) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') !=null ? prefs.getString('userName'):'0';
    return 'end';
  }

}


// 首页app标题编写
class AppTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(220)),
      child: Text(
          base_title, 
          style: TextStyle(
            fontSize: ScreenUtil().setSp(50), 
            color: base_titleColor
          ),
          textAlign: TextAlign.center,
      ),
    );
  }
}

// 首页轮播组件编写
class SwiperDiy extends StatelessWidget{

  final List<String> swiperDataList;
  final String userName;
  SwiperDiy({Key key,this.swiperDataList, this.userName}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(120)),
      height: ScreenUtil().setHeight(384 + 80),
      width: ScreenUtil().setWidth(500),
      child: Swiper(
        itemBuilder: (BuildContext context, int index){
                
          return InkWell(
            onTap: (){
                  SharedPreferences.getInstance().then((val){
                    if(val.getString('userName')!= null ) {
                      _getExhibitionInfoByAreaName(context, swiperDataList[index]);
                      //检查用户相应权限
                      int userAdmin =  val.getInt('admin');
                      if (userAdmin != null || userAdmin == 0) {
                        Exhibition exhibition = Provide.value<MainPageProvide>(context).exhibition;
                        switch (userAdmin) {
                          case 1:// 最高权限
                            _selectExhibition(exhibition,context);
                            break;
                          case 2:// 故宫权限
                            _selectExhibition(exhibition,context);
                            break;
                          case 11:// 珠海权限
                            if (exhibition.exhibitionAreaName == '珠海紫檀宫') {
                              _selectExhibition(exhibition,context);
                            } else {
                              Fluttertoast.showToast(
                                msg: "您并非该区域管理员。",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            }
                            break;
                          case 20:// 西安权限
                            if (exhibition.exhibitionAreaName == '西安兵马俑') {
                              _selectExhibition(exhibition,context);
                            } else {
                              Fluttertoast.showToast(
                                msg: "您并非该区域管理员。",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            }
                            break;
                          default:
                        }
                      } else {
                        // 让用户重新登陆
                        Fluttertoast.showToast(
                          msg: "版本更新，请重新登陆!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                        );
                        Application.router.navigateTo(context, "/login");
                        }
                    } else {
                      Fluttertoast.showToast(
                        msg: "尚未登陆，请登陆!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                      Application.router.navigateTo(context, "/login");
                    }
                  });
            
            },
            child: Column(
              children: <Widget>[
                new Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/${swiperDataList[index] == '北京'?'beijing':swiperDataList[index] == '珠海'?'zhuhai':swiperDataList[index] == ' 上海'?'shanghai':swiperDataList[index] == '天津'?'tianjin':'xian'}.jpeg"),
                      fit: BoxFit.fill
                    ), 
                    borderRadius: new BorderRadius.circular(ScreenUtil().setSp(20)),
                  ),
                  height: ScreenUtil().setHeight(375),
                  width: ScreenUtil().setWidth(445),
                ),
                Text(
                  '${swiperDataList[index]}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(45),
                  ),
                ),
              ],
            )
          );

        },
        itemCount: swiperDataList.length,
        autoplay: false,
        viewportFraction: 0.8,
        scale: 0.5,
      ),
    );
  }

  void _selectExhibition(Exhibition exhibition ,BuildContext context){
    if (exhibition.exhibitionAreaName != null && exhibition.exhibitionAreaName.length >0) {
      Application.router.navigateTo(context, "/index?id=${exhibition.exhibitionId}");
    } else {
      Fluttertoast.showToast(
        msg: "该区域未获权限。",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<String> _getExhibitionInfoByAreaName(BuildContext context , String areaName) async {
    await Provide.value<MainPageProvide>(context).getFirstExhibitionByString(areaName);
    return 'end';
  }
  
}
