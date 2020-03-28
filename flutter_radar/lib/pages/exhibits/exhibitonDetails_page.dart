import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/model/host_model.dart';
import 'package:flutter_radar/model/main_model.dart';
import 'package:flutter_radar/pages/pin/map_view.dart';
import 'package:flutter_radar/pages/pin/pin.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:flutter_radar/routers/application.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ExhibitionDetailsPage extends StatelessWidget {

  int exhibitionId;
  ExhibitionDetailsPage(this.exhibitionId);

  int ontapCount = 0;
  @override
  Widget build(BuildContext context){

    Exhibition exhibition = Provide.value<MainPageProvide>(context).exhibition;
    List<Exhibits> rfidlist=[];
    Provide.value<HostListProvide>(context).createPinsWithHostByExhibition(exhibitionId);

    final Widget _floatingActionButtonExtended = FloatingActionButton.extended(
      onPressed: () {

        Application.router.navigateTo(context, "/exhibits?id=${exhibition.exhibitionId}");

      },
      icon: Icon(Icons.announcement),
      label: Text('展品介绍'),
    );

    return Scaffold(
      floatingActionButton: _floatingActionButtonExtended,
      //配置悬浮按钮的位置
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('${exhibition.exhibitionName}'),
      ),

      backgroundColor: Colors.white,

      body: Column(
        children: <Widget>[
          Expanded(
            child:  MakeMapPage(exhibitionId),
          ),

          // Stack(
          //   children: <Widget>[MakeMapPage()],
          // ),


          // Expanded(
          //   child: Stack(
          //     children: <Widget>[MakeMapPage()],
          //   )
          // ),


            // Text('测试程序图片缩放功能是否删掉了')
            
            // ExtendedImage.asset(
            //   'images/珠海${exhibition.exhibitionName}.jpg',
            //   fit: BoxFit.contain,
            //   mode: ExtendedImageMode.gesture,
            //   initGestureConfigHandler: (state) {
            //     return GestureConfig(
            //         minScale: 0.9,
            //         animationMinScale: 0.7,
            //         maxScale: 3.0,
            //         animationMaxScale: 3.5,
            //         speed: 1.0,
            //         inertialSpeed: 100.0,
            //         initialScale: 1.0,
            //         inPageView: false,
            //         //  InitialAlignment.center,
            //         );
            //   },
            // ),

            // Image(
            //   image: AssetImage("images/珠海${exhibition.exhibitionName}.jpg"),
            //   fit: BoxFit.cover,
            // ),
          // ),

          Expanded(
            child: FutureBuilder(
              future: _getrfidList(context),
              builder: (context, snapshot){
                if (snapshot.hasData != null) {
                  
                  // 看看能不能加成动态获取
                  rfidlist = Provide.value<SocketNotifyProvide>(context).warningListByExhibition;
                  
                  //增加内容 倒序输出数字
                  ontapCount = rfidlist.length;

                  // _getrfidList(context);
                  return Container(
                    color: Colors.white,
                    child: Stack(
                      children: <Widget>[
                        Provide<SocketNotifyProvide>(
                          builder: (context,child,val){
                            rfidlist = Provide.value<SocketNotifyProvide>(context).warningListByExhibition;
                            return ListView.builder(
                              itemCount: rfidlist.length,
                              itemBuilder: (context, index){
                                return _infoCell(context, rfidlist[index], index);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Text('无新增报警');
                }
              },
            ),
          )
        ],
      ),
    );
  }


  Widget _infoCell(context , Exhibits item, int index) {
      return Container(
      margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), 5.0, ScreenUtil().setWidth(30), 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(ScreenUtil().setSp(20)),
      ),

      child: Stack(
        children: <Widget>[
          //信息文本显示的内容
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5 ,),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(width: 0,color: Colors.black12)
                    )
                  ),
                  child: Center(
                    child: Text('${ontapCount - index}'),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 10),
                child: _titleContent(context, '文物号：', item.exhibitsId),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
                child: _titleContent(context, '名称：', item.exhibitsName),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5),
                child: _titleContent(context, '位置：', item.exhibitsRecommend != null ? item.exhibitsRecommend :''),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5,bottom: 15),
                child: _titleContent(context, '时间：', formatDate(DateTime.parse(item.timeStr).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]))
              ),

              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5,bottom: 15),
                child: _titleContent(context, '报警类型：', item.warningType != null ?item.warningType : '')
              ),
              
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(40) ,top: 5,bottom: 15),
                child: RaisedButton(
                child: Text('确认告警'),
                  color: Colors.lightGreen,
                  elevation: 10,
                  onPressed: () {
                    
                    Fluttertoast.showToast(
                      msg: "正在确认该条报警消息...",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                    // 执行方法  改写数据库
                    ontapCount --;
                    
                    // 对本地持久化进行存储功能
                    _preferencesList(context,item);
                  },
                ),
              )
            ],
          ),

          // 文物图片
          Positioned( right:  10, top: ScreenUtil().setHeight(50),
            child: CachedNetworkImage(
              imageUrl: "${item.exhibitsImg}",
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          )
        ],
      )
    );
  }

// 添加本地数据。  消除报警
  void _preferencesList(BuildContext context, Exhibits item) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String warningStr = '';
    if (item.isJpush) {
      var timeStr = formatDate(DateTime.parse(item.timeStr).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
      warningStr = '{"timeStr":"${timeStr}","rfidId":"${item.rfidId}","exhibitsId":"${item.exhibitsId}"}';
    } else {
      warningStr = '{"timeStr":"${item.timeStr}","rfidId":"${item.rfidId}","exhibitsId":"${item.exhibitsId}"}';
    }
    
    //先获取之前的数据
    List<String> sureWarningList =  prefs.getStringList('SureWarningList');
    if (sureWarningList == null) {
      sureWarningList = new List<String>();
    }
    sureWarningList.add(warningStr);
    // 本地持久化数据
    prefs.setStringList('SureWarningList', sureWarningList);
    
    Provide.value<SocketNotifyProvide>(context).subtractWarningListByRFID(context, item);
    Provide.value<SocketNotifyProvide>(context).selecPinByExhibition(item.exhibitionId);
  }

  Widget _titleContent(context, titleString, itemString) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          // width: ScreenUtil().setWidth(app_width),
          child: Text(
            titleString + itemString,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
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

  Future<String> _getrfidList(BuildContext context) async {
    await Provide.value<SocketNotifyProvide>(context).checkRFIDListByExhibitionId(context ,exhibitionId);
    return 'end';
  }
}




//地图展示页面
class MakeMapPage extends StatefulWidget {

  // String imageStr;
  int exhibitionId;
  
  MakeMapPage(this.exhibitionId);

  @override
  _MakeMapPageState createState() => _MakeMapPageState(exhibitionId);
}

class _MakeMapPageState extends State<MakeMapPage> {

  // String imageNameStr;
  int exhibitionId;

  _MakeMapPageState(this.exhibitionId);

  // int _genId;
  // PinList _pins = Provide.value<SocketNotifyProvide>(context).pinList;

  String endImageStr;

  @override
  void initState() {
    endImageStr = exhibitionId == 8 ? 'images/zitangongxiting.jpg':exhibitionId == 9 ? 'images/zitangongzhongting.jpg':'images/zitangongdongting.jpg';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provide<SocketNotifyProvide>(
      builder: (context ,child,val){
        
        List<Host> warningList = Provide.value<HostListProvide>(context).hostListByExhbition;
        PinList _pins = Provide.value<SocketNotifyProvide>(context).pinByExhibitionList;
        //加入主机pin
        for (Host h in warningList) {
          //添加临展主机大头针标示
          Pin p = new Pin(h.hostId, new Offset(h.mobileLeft, h.mobileTop),true);
          _pins.list.add(p);
        }

        return MapView(
          AssetImage(endImageStr),
          _pins,
          (p, pos) {
            /// 2. 这里是变换图钉
            setState(() {
              _pins.curFocus = p;
            });

            ///
            /// 3. 这里展示自定义的Widget
            if (p != null)
            BotToast.showAttachedWidget(
                // 3.1 这个表示弹出的起泡相对于点击的位置进行一定偏移
                target: pos.translate(100, 50),
                attachedBuilder: (onCancel) => Material(
                  child: Padding(
                      child: Text(p.isHost? '这是临展主机${p.pinId}':'这是报警标签'), padding: EdgeInsets.all(10)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                ),
              );
          },

          ///
          /// 4. 这里是添加两种Pin的图片
          AssetImage('images/hongdengyichang.png'),
          AssetImage('images/landengzhengchang.png'),
        );
      },
    );
    
  }
}