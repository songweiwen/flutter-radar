import 'dart:typed_data';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/model/warning_model.dart';
import 'package:flutter_radar/provide/warningManage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getWarningManage(context),
        builder: (context, snapshot){
          List warningList = Provide.value<WarningManageProvide>(context).warningList;
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

                    Provide<WarningManageProvide>(
                      builder: (context,child,childCategory){
                        warningList = Provide.value<WarningManageProvide>(context).warningList;
                        return ListView.builder(
                          itemCount: warningList.length,
                          itemBuilder: (context,index){
                            return WarningCell(warningList[index]);
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

  Future<String> _getWarningManage(BuildContext context) async {
    await Provide.value<WarningManageProvide>(context).getWarningManageList();
    return 'end';
  }
}

class WarningCell extends StatelessWidget {

  final Warning item;
  WarningCell(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), 5.0, ScreenUtil().setWidth(30), 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(ScreenUtil().setSp(20)),
      ),

      child: Column(
        children: <Widget>[

          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 10),
            child: _titleContent(context, '时间：', formatDate(DateTime.parse(item.beginTime).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])),
          ),
          
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
            child: _titleContent(context, '位置：', item.exhibitsRecommend),
          ),
          
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
            child: _titleContent(context, '文物编号：', item.exhibitsId),
          ),

          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
            child: _titleContent(context, '文物名称：', item.exhibitsName),
          ),
          


          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5,bottom: 15),
            child: _titleContent(
              context, '报警类型：', 
              _getWarningType(item)
            )
          ),
          
        ],
      ),
    );
  }

  String _getWarningType(Warning item){
    String warningTyep;
    if (item.comment.length > 0) {
      warningTyep = '失联报警';
    }  else{
      String typeStr = item.type.substring(item.type.length -2, item.type.length);
      Uint8List u = Uint8List.fromList([_hexToInt(typeStr)]);
      if ( u[0]&0x4F == 0x4F) {
        warningTyep = '移动报警';
      } 
      if ( u[0]&0x80 == 0x80) {
        warningTyep = warningTyep + ',欠电报警';
      } 
      if (item.comment == '失联') {
        warningTyep = '失联报警';
      }
    }

    return warningTyep;
  }

  // 16进制字符串转 int
  static int _hexToInt(String hex) {
    int val = 0;
    int len = hex.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = hex.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("Invalid hexadecimal value");
      }
    }
    return val;
  }

  Widget _titleContent(context, titleString, itemString) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            titleString + itemString,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: itemString == '移动报警'? Colors.red:itemString == '移动报警,欠电报警'?Colors.orange: itemString == '失联报警' ? Colors.brown:Colors.black
            ),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }
}