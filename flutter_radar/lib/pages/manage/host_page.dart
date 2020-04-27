import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/model/host_model.dart';
import 'package:flutter_radar/model/main_model.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routers/application.dart';

class HostPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Exhibition exhibition = Provide.value<MainPageProvide>(context).exhibition;
    return Scaffold(

      body: FutureBuilder(
        future: _gethostList(context,exhibition),
        builder: (context, snapshot){
          List<Host> warningList = Provide.value<HostListProvide>(context).hostList;
          if (snapshot.hasData && warningList != null) {

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg2.jpg"),
                  fit: BoxFit.fill
                )
              ),
              child: Scrollbar(
                
                  child: Stack(
                    children: <Widget>[
                      Provide<HostListProvide>(
                        builder: (context,child,childCategory){
                          warningList = Provide.value<HostListProvide>(context).hostList;
                          return ListView.builder(
                            itemCount: warningList.length,
                            itemBuilder: (context,index){
                              return _infoCell(context,warningList[index]);
                            },
                          );
                        },
                      ),

                    ],
                  ),
               
              )
            );
          } else {
            return Text('正在加载。。。。');
          }
        },
      ),
    );
  }

  Future<String> _gethostList(BuildContext context, Exhibition exhibition) async {
    await Provide.value<HostListProvide>(context).getHostList(_checkExhibitionIdWithHost(exhibition.exhibitionId));
    return 'end';
  }

int _checkExhibitionIdWithHost(int eId){
    var exhibitionId;
    if (eId <11) exhibitionId = 11;
    if (eId > 12 && eId <30) exhibitionId = 20;
    return exhibitionId;
  }

  Widget _infoCell(context , Host item) {

      return Container(
      margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), 5.0, ScreenUtil().setWidth(30), 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(ScreenUtil().setSp(20)),
      ),

      child:Stack(
        children: <Widget>[

          // 临展主机状态显示位
          Padding(
            padding: EdgeInsets.only( left: ScreenUtil().setWidth(app_width - 300),top: ScreenUtil().setHeight(20)),
            child: MaterialButton(
              onPressed: (){},
              child: Text(item.isWarning?'故障':'正常'),
              color:  item.isWarning? Colors.red:Colors.lightGreen,
            ),
          ),
          
          // 临展主机设置按钮
            Padding(
              padding: EdgeInsets.only( left: ScreenUtil().setWidth(app_width - 300),top: ScreenUtil().setHeight(120)),
              child: FutureBuilder(
                future: checkAdmin(),
                builder: (context , AsyncSnapshot<bool>snapshot){
                  return Offstage(
                    offstage: snapshot.data == null ? true: snapshot.data,
                    child: MaterialButton(
                      onPressed: (){
                        Application.router.navigateTo(context, "/sethostpage?id=${item.hostId}");
                      },
                      color: Colors.purple,
                      child: Text('参数'),
                    ),
                  );
                }
              )
            ),

            Column(
            children: <Widget>[

              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 10),
                child: _titleContent(context, item.hostId == 7 ?'测试主机':'临展主机ID号：', item.hostId == 7 ?'':item.hostId.toString()),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
                child: _titleContent(context, '位置：', item.hostRecommend),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
                child: _titleContent(context, '板卡状态：', item.hostState),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5,bottom: 15),
                child: _titleContent(context, '电源状态：', item.hostElectric)
              ),

              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5,bottom: 15),
                child: _titleContent(context, '更新时间：', formatDate(DateTime.parse(item.updateTime).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]))
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _titleContent(context, titleString, itemString) {
    return Row(
      children: <Widget>[
        Text(
          titleString + itemString,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: ((itemString == '故障')||(itemString == '交流故障')) ? Colors.red : Colors.black
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
  
  Future<bool> checkAdmin() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt('admin') ==1 ? false: true;
  }

}