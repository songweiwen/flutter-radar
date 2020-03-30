import 'package:flutter/material.dart';
import 'package:provide/provide.dart';

import '../../provide/socketNotify.dart';

// 设置临展主机
class SetHostPage extends StatelessWidget {

  final int hostId;
  SetHostPage(this.hostId);

  @override
  Widget build(BuildContext context) {

    //将临展主机和context带入 组装事件代理  并初始化访问临展主机参数读取。
    Provide.value<SocketNotifyProvide>(context).setSocketRGJCStatus(9, hostId.toString());

    return Scaffold(
      // app_title + back
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('${hostId}号临展主机'),
      ),
    );
  }

  void _initDataBase(BuildContext context) {
    
  }
}