import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/model/host_model.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

class HostPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    // final Widget _floatingActionButtonExtended = FloatingActionButton.extended(
    //   onPressed: () {

    //   },
    //   icon: Icon(Icons.announcement),
    //   label: Text('检测主机'),
    // );
    return Scaffold(
      
      // floatingActionButton: _floatingActionButtonExtended,
      // //配置悬浮按钮的位置
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: FutureBuilder(
        future: _gethostList(context),
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

  Future<String> _gethostList(BuildContext context) async {
    await Provide.value<HostListProvide>(context).getHostList();
    return 'end';
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

          Padding(
            padding: EdgeInsets.only( left: ScreenUtil().setWidth(app_width - 300),top: ScreenUtil().setHeight(20)),
            child: MaterialButton(
              onPressed: (){

                // Fluttertoast.showToast(
                //   msg: "正在发送人工检测，请稍后。",
                //   toastLength: Toast.LENGTH_SHORT,
                //   gravity: ToastGravity.CENTER,
                // );

                // Provide.value<HostListProvide>(context).getHostStateById(item.hostId);

                // String hostIdStr ;
                // if (item.hostId < 10) {
                //   hostIdStr = '000'+ item.hostId.toString();
                // }
                // if(item.hostId < 100 && item.hostId > 10) {
                //   hostIdStr = '00'+ item.hostId.toString();
                // }
                // if( item.hostId < 1000 && item.hostId >= 100) {
                //   hostIdStr = '0'+ item.hostId.toString();
                // }
                // if( item.hostId > 1000) {
                //   hostIdStr = item.hostId.toString();
                // }
                // Provide.value<SocketNotifyProvide>(context).setSocketStatus(9,hostIdStr);
              },
              child: Text(item.isWarning?'故障':'正常'),
              color:  item.isWarning? Colors.red:Colors.lightGreen,
            ),
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
  
}