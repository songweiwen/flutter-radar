import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/model/servers_model.dart';
import 'package:flutter_radar/provide/servers_provide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';


class ServersPage extends StatelessWidget {

  ServersModel serversModel = new ServersModel();

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
        title: Text('服务器信息'),
      ),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _getServersModel(context),
          builder: (context, snapshot){
            if (snapshot.hasData != null && snapshot.hasData != false) {
              return Provide<ServersProvide>(
                builder: (context , child, val){
                  serversModel = val.serversModel;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
    
                      Text(
                        '服务器总重启次数：${serversModel.data.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                        ),
                      ),

                      ListView.builder(
                        itemCount: serversModel.data.length,
                        shrinkWrap: true,
                        itemBuilder: (context ,index ){
                          return _infoCell(context,serversModel.data[index]);
                        }
                      )
                    ],
                  );
                },
              );
            } else {
              // 读取不到服务器信息的时候  
              return Text('加载中...');
            }
          },
        )
      ),
    );
  }
  
  Widget _infoCell(BuildContext context, Servers servers) {
    return Container(
      margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), 5.0, ScreenUtil().setWidth(30), 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(ScreenUtil().setSp(20)),
      ),
      child: Row(
        children: <Widget>[
          Text('报警时间：${formatDate(DateTime.parse(servers.serversTime).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])}'),
          Text('报警原因：${servers.serversDescribe}')
        ],
      ),
    );
  }

  Future<String> _getServersModel(BuildContext context) async {
    await Provide.value<ServersProvide>(context).getServersStatusToProvide();
    return 'end';
  }
}