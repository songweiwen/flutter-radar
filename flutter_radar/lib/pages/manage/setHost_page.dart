import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

import '../../provide/socketNotify.dart';

// 设置临展主机
class SetHostPage extends StatelessWidget {

  final int hostId;
  SetHostPage(this.hostId);

  @override
  Widget build(BuildContext context) {

    //将临展主机和context带入 组装事件代理  并初始化访问临展主机参数读取。
    // Provide.value<SocketNotifyProvide>(context).setSocketRGJCStatus(9, hostId.toString());

    // 告警次数  
    TextEditingController hostWarningC = TextEditingController();
    // 总告警次数   
    TextEditingController hostWarningTotalC = TextEditingController();
    // 展柜标签告警次数 
    TextEditingController rFIDWarningC = TextEditingController();
    // 展柜标签总次数
    TextEditingController rFIDWarningTotalC = TextEditingController();

    final Widget _floatingActionButtonExtended = FloatingActionButton.extended(
      onPressed: () {

        Provide.value<SocketNotifyProvide>(context).setSocketStatus(9, hostId.toString());

      },
      icon: Icon(Icons.announcement),
      label: Text('读取参数'),
    );

    return Scaffold(
      floatingActionButton: _floatingActionButtonExtended,
      //配置悬浮按钮的位置
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

      // 内容主体 
      body:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 界面需要设置的参数。  告警次数  总告警次数   展柜标签告警次数  展柜标签总次数
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Text(
                  '告警次数',
                  textAlign: TextAlign.left,
                  style:TextStyle(
                    fontSize: ScreenUtil().setSp(30)
                    
                  ),
                ),

                Provide<SocketNotifyProvide>(
                  builder:(context, child, val) {
                    int hostTotalCount = Provide.value<SocketNotifyProvide>(context).hostWarningCount;
                    hostWarningC.text = hostTotalCount.toString();
                    return Expanded(
                      child: new TextField(
                        keyboardType: TextInputType.phone,
                        controller: hostWarningC,
                        textAlign: TextAlign.center,
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      )
                    );
                  }
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '总告警次数',
                  textAlign: TextAlign.left,
                  style:TextStyle(
                    fontSize: ScreenUtil().setSp(30)
                  ),
                ),
                
                Provide<SocketNotifyProvide>(
                  builder:(context, child, val) {
                    int hostTotalCount = Provide.value<SocketNotifyProvide>(context).hostWarningTotalCount;
                    hostWarningTotalC.text = hostTotalCount.toString();
                    return Expanded(
                      child: new TextField(
                        keyboardType: TextInputType.phone,
                        controller: hostWarningTotalC,
                        textAlign: TextAlign.center,
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      )
                    );
                  }
                ),

              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '展柜标签告警次数',
                  textAlign: TextAlign.left,
                  style:TextStyle(
                    fontSize: ScreenUtil().setSp(30)
                  ),
                ),
                
                Provide<SocketNotifyProvide>(
                  builder:(context, child, val) {
                    int hostTotalCount = Provide.value<SocketNotifyProvide>(context).rFIDWarningCount;
                    rFIDWarningC.text = hostTotalCount.toString();
                    return Expanded(
                      child: new TextField(
                        keyboardType: TextInputType.phone,
                        controller: rFIDWarningC,
                        textAlign: TextAlign.center,
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      )
                    );
                  }
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '展柜标签总次数',
                  textAlign: TextAlign.left,
                  style:TextStyle(
                    fontSize: ScreenUtil().setSp(30)
                  ),
                ),
                
                Provide<SocketNotifyProvide>(
                  builder:(context, child, val) {
                    int hostTotalCount = Provide.value<SocketNotifyProvide>(context).rFIDWarningTotalCount;
                    rFIDWarningTotalC.text = hostTotalCount.toString();
                    return Expanded(
                      child: new TextField(
                        keyboardType: TextInputType.phone,
                        controller: rFIDWarningTotalC,
                        textAlign: TextAlign.center,
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      )
                    );
                  }
                ),
              ],
            ),
          
            // 设置参数按钮 
            Center(
              child: MaterialButton(
                onPressed: (){

                  print('您要设置的参数是 告警次数${hostWarningC.text} 总告警次数 展柜标签告警次数 展柜标签总次数');

                  Provide.value<SocketNotifyProvide>(context).setSocketStatus(10, hostId.toString());
                },
                child: Text('设置参数到主机'),
              ),
            )

          ],
        ),
      )
    );
  }
 

}