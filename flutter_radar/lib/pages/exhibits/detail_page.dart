import 'package:flutter/material.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/provide/exhibitsList.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

class DetailsPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    Exhibits exhibits = Provide.value<ExhibitsListProvide>(context).exhibits;
    return Scaffold(
      
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('${exhibits.exhibitsName}'),
      ),

      body: Container(
        height: ScreenUtil().setHeight(app_height),
        width: ScreenUtil().setWidth(app_width),
        decoration: BoxDecoration(
          image: DecorationImage(
          image: AssetImage("images/bg3.jpg"),
          fit: BoxFit.fill,
          )
        ),
        child: _columnByExhibition(context,exhibits),
      )
    );
  }

    Widget _columnByExhibition(context, Exhibits e) {
    return ListView(
      children: <Widget>[
        _backTopImage(context, e),
        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(60),left: ScreenUtil().setWidth(60)),
          child: Text(
            '${e.exhibitsName}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(34)
            ),
          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(16),left: ScreenUtil().setWidth(60),right: ScreenUtil().setWidth(50)),
          child: Text(
            '${e.exhibitsRecommend}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: Color(0xFF7CBDB3)
            ),
          ),
        ),
        
      ],
    );
  }

  //带有返回按钮的 顶部imageview
  Widget _backTopImage(context,Exhibits e) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          child: Image(
            image: NetworkImage("${e.exhibitsImg}"),
            fit: BoxFit.fill,
            height: ScreenUtil().setHeight(app_width),
            width: ScreenUtil().setWidth(app_width),
          ),
        ),

        // 添加app 返回按钮
        // Positioned(
        //   child: new IconButton(
        //     icon: new Icon(Icons.navigate_before),
        //     color: Colors.white,
        //     onPressed: (){
        //       Navigator.pop(context);
        //     },
        //   ),
        // )
      ],
    );
  }
}
