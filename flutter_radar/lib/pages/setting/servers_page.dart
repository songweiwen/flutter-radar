import 'package:flutter/material.dart';
import 'package:flutter_radar/model/servers_model.dart';
import 'package:flutter_radar/provide/servers_provide.dart';
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
            if (snapshot.hasData != null) {
              return Provide<ServersProvide>(
                builder: (context , child, val){
                  serversModel = Provide.value<ServersProvide>(context).serversModel;
                  return Column(
                    children: <Widget>[
                      // 横向列表。 两个服务器信息
                      Row(
                        children: <Widget>[
                          //
                          Text('服务器总重启次数：${serversModel.data.length}')
                        ],
                      ),

                      ListView.builder(
                        itemCount: serversModel.data.length,
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
      child: Row(
        children: <Widget>[
          Text('报警时间：${servers.serversTime}'),
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