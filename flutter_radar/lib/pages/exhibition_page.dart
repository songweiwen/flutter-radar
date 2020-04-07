import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/model/main_model.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/routers/application.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provide/provide.dart';


class ExhibitionPage extends StatelessWidget {
  
  int socketStatus;
  List<Exhibits> warningCount =List<Exhibits>();
  List<Exhibits> exhibitsList = List<Exhibits>();

  @override
  Widget build(BuildContext context) {
    
    Exhibition exhibition = Provide.value<MainPageProvide>(context).exhibition;
    List<Exhibition> areaNameList =Provide.value<MainPageProvide>(context).areaNameList;
    Provide.value<MainPageProvide>(context).getAllRFIDByExhibition({'exhibitsArea':exhibition.exhibitionAreaName });
    Provide.value<SocketNotifyProvide>(context).setWarningListByAll(context);

    return Stack(
      children: <Widget>[
        // 展厅的结构图
        Positioned( top: ScreenUtil().setHeight(10), right: 0, left: 0, bottom: ScreenUtil().setHeight(app_height -(app_height - app_width)),
          child: ExtendedImage.asset(
            'images/zhuhaijiegoutu.jpg',
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
                return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 3.0,
                    animationMaxScale: 3.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                    //  InitialAlignment.center,
                );
              },
          )
        ),
        
        // 展厅详情进入按钮
        Provide<MainPageProvide>(
                  builder: (context,child,childCategory){
                    return Center(
                      child: Container(
                        height: ScreenUtil().setHeight(150),
                        width: ScreenUtil().setWidth(app_width),
                        child:ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: areaNameList.length,
                          itemBuilder: (context,index){

                            return _rightInkWell(context,index,areaNameList[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),

            // 两个按钮  展品列表和展厅介绍
        Positioned(right: 10, bottom: 0, 
          child: _stackMyBotton(context,exhibition),
        ),


        Positioned(left: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10),
          child: Row(
            children: <Widget>[

              // 网络状态
              Container(
                padding: EdgeInsets.only(left: 10),
                child:ConnectivityWidgetWrapper(
                  stacked: false,
                  offlineWidget: RaisedButton(
                    onPressed: null,
                    color: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '连接中',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                      
                          CupertinoActivityIndicator(radius: 8.0),
                        ],
                      ),
                    ),
                  ),
                  child: Provide<SocketNotifyProvide>(
                    builder: (context,child,val){
                      socketStatus = Provide.value<SocketNotifyProvide>(context).server_HeartBest;
                      return RaisedButton(
                        color: socketStatus == 3? Colors.orange  : Colors.lightGreen,
                        child: Text(
                          socketStatus == 3? '正在尝试重连' : '网络正常',
                        ),
                        onPressed: (){

                        },
                      );
                    },
                  ),
                ),
              ),

              // // 报警记录查询
              Container(
                padding: EdgeInsets.only(left: 10),
                child: MaterialButton(
                  color: Colors.lightGreen,
                  child: Text(
                    '报警查询'
                  ),
                  onPressed: (){
                    Fluttertoast.showToast(
                      msg: "正在查询报警记录中。请稍后。",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                    // Provide.value<WarningManageProvide>(context).getWarningManageList();
                    Provide.value<SocketNotifyProvide>(context).setWarningListByAll(context);
                    
                  },
                ),
              )
              
            ],
          )
        ),
      ],

    );
  }


  Widget _rightInkWell(BuildContext context, int index,Exhibition item) {
    return Container(
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
      width: ScreenUtil().setWidth(app_width /3),
      height: ScreenUtil().setHeight(120),
      child: Provide<SocketNotifyProvide>(
        builder: (context,child,val){
          warningCount = [];
          warningCount = Provide.value<SocketNotifyProvide>(context).warningListByRFID;
          bool checkInfo = false;
          for (var w in warningCount) {
            if(w.exhibitionId == item.exhibitionId) {
              checkInfo = true;
            } 
          }
          return RaisedButton(
            child: Text( item.exhibitionName,),
            color: checkInfo? Colors.red :Colors.lightGreen,
            elevation: 10,
            onPressed: () {

              Provide.value<SocketNotifyProvide>(context).selecPinByExhibition(item.exhibitionId);

              Provide.value<MainPageProvide>(context).getExhibitionInfoById(item.exhibitionId);
              Application.router.navigateTo(context, "/exhibitiondetailspage?id=${item.exhibitionId}");
            },
          );
        }
      ),
    );
  }

//展馆介绍按钮
  Widget _stackMyBotton(context ,Exhibition exhibition) {
    return Container(
      child: Column(
        children: <Widget>[
          _myBotton(context, '展馆介绍', 'exhibitionDetails',exhibition)
        ],
      ),
    );
  }


  Widget _myBotton (context, titleString, actionString, Exhibition exhibition){
    return Container(
      margin: EdgeInsets.only(left: 10, bottom: 10),
      child: FlatButton(
        onPressed: () {
          Application.router.navigateTo(context, "/exhibitionrecommdpage?id=${exhibition.exhibitionId}");
        },
        child: Text(
          titleString,
          style: TextStyle(
            color: Color(0xFFE2EFEC)
          ),
        ),
        color: exhibition_bottonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      ),
    );
  }

}
