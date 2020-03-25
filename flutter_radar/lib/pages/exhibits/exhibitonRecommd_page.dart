import 'package:flutter/material.dart';
import 'package:flutter_radar/model/main_model.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

class ExhibitionRecommdPage extends StatelessWidget {

  final int exhibitionId;

  ExhibitionRecommdPage(this.exhibitionId);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getExhibitionInfo(context),
        builder: (context, snapshot){
          Exhibition exhibition = Provide.value<MainPageProvide>(context).exhibition;
          if( exhibition !=null){
            return _detailsByExhibition(context,exhibition);
          } else {
            return Text('加载中。。。。。');
          }
        },
      ),
    );
  }


  Widget _detailsByExhibition (context, Exhibition e) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('${e.exhibitionAreaName}'),
      ),

      body: Container(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(150),left: ScreenUtil().setWidth(60),right: ScreenUtil().setWidth(50)),
              child: Text(
                '${e.exhibitionRecommend}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  color: Colors.black
                ),
              ),
            ),
          ),
        )
      ),
    );
  }


  Future _getExhibitionInfo(BuildContext context) async{
    await Provide.value<MainPageProvide>(context).getExhibitionInfoById(exhibitionId);
    return 'end';
  }
}