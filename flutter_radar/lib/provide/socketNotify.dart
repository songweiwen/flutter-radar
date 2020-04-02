import 'dart:convert';
import 'dart:typed_data';
import 'package:convert_hex/convert_hex.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/model/host_model.dart';
import 'package:flutter_radar/model/warning_model.dart';
import 'package:flutter_radar/pages/pin/pin.dart';
import 'package:flutter_radar/provide/hostList.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_radar/provide/warningManage.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketNotifyProvide with ChangeNotifier{
  
  int status = 0; // 0 socket 未连接  1 已连接  2 与服务器失联   9 发送消息执行

  String sendBody;
  String engineId='';

  int server_HeartBest = 0;


  List<RFIDSocketModel> rfidList = List<RFIDSocketModel>();
  List<Exhibits> warningListByRFID = List<Exhibits>();
  List<Exhibits> warningListByExhibition = List<Exhibits>();

  // List<Pin> pinList = List<Pin>();
  PinList pinList = PinList();
  PinList pinByExhibitionList = PinList();

  // 临展主机目前可设置的参数
  int hostWarningCount = 0;
  int hostWarningTotalCount = 0;
  int rFIDWarningCount = 0;
  int rFIDWarningTotalCount = 0;

  // 检查服务器心跳状态
  checkHeartBest() {
    server_HeartBest += 1;
    if(server_HeartBest >3) {
      server_HeartBest = 1;
    }
  }

  // 告知sokcet状态
  setSocketStatus(int statusId, String str) {
    sendBody = str;
    status = statusId;
    notifyListeners();
  }


  // 程序返回时  把已经滞空过的参数还原 
  clearCount(){
    hostWarningCount = 0;
    hostWarningTotalCount = 0;
    rFIDWarningCount = 0;
    rFIDWarningTotalCount = 0;
  }

// 准备查检数据
  setJpushContentCheck(String content, BuildContext context, String timeStr) {
    // if (rfidList.length == 0) {
      String warningTypes = '';
      List<int> buffer  =  new List<int>();
      for(int i = 0 ; i < content.length; i +=2) {
        String sizeStr = content.substring(i,i+2);
        if (i == 12) {
          if (sizeStr == '21') {
            warningTypes = '失联';
          }
          if(sizeStr == '04') {
            warningTypes = '位移';
          }
        }
        buffer.add(_hexToInt(sizeStr));
      }
      if (buffer.length != 0) {
        int cardLength = Hex.decode(Hex.encode(buffer[9]) + Hex.encode(buffer[10]));
        List<int> cardBuffer = buffer.sublist(7, 7+2+2+cardLength);
        setWarningSocketModel(cardBuffer,context,warningTypes,timeStr,true);
      }
      
    // } // rfidlist 不大于 0 不作处理
  }

  // 解析 人工检测 应答主要属性
  setCheckRGSocketModel(List<int>buffer, BuildContext context , String type) {
    if (type == '人工检测') {
      
      if (buffer[4] == 0x05) { //人工检测确认
        
        int hostId = Hex.decode(Hex.encode(buffer[5]) + Hex.encode(buffer[6]));
        int exc = Hex.decode(Hex.encode(buffer[13]));
        int banka = Hex.decode(Hex.encode(buffer[16]));

        Host h = new Host();
        h.hostId = hostId;
        h.hostElectric = exc == 2 ? '交流故障':'交流正常';
        h.hostState = banka == 0? '正常': '故障';
        Provide.value<HostListProvide>(context).changeHostList(h);
      }


    } else {

      if (buffer[4] == 0x08) {
        
        int hostId = Hex.decode(Hex.encode(buffer[5]) + Hex.encode(buffer[6]));
        int exc = Hex.decode(Hex.encode(buffer[7]));
        int banka = Hex.decode(Hex.encode(buffer[0]));
        Host h = new Host();
        h.hostId = hostId;
        h.hostElectric = exc == 2 ? '交流故障':'交流正常';
        h.hostState = banka == 0? '正常': '故障';
        Provide.value<HostListProvide>(context).changeHostList(h);
      }
    }
  }


    // 解析  读取参数 的主要属性
  setCheckReadHostParameter(List<int>buffer, BuildContext context , String type) {
    // 是否需要鉴定当前数据包发送给本手机号。=？
    // 如果不需要鉴定直接对读取到的参数进行数值获取。

    hostWarningCount = buffer[13];
    hostWarningTotalCount = buffer[14];
    rFIDWarningCount = buffer[15];
    rFIDWarningTotalCount = buffer[16];

    notifyListeners();
  }

  // 解析报警主要属性
  setWarningSocketModel(List<int>buffer, BuildContext context , String warningTypes, String timeStr, bool isJpush) {
    rfidList.clear();
    engineId = Hex.decode(Hex.encode(buffer[0]) + Hex.encode(buffer[1])).toString();
    int cardLength = Hex.decode(Hex.encode(buffer[2]) + Hex.encode(buffer[3]));
    List<int> cardBuffer =  buffer.sublist(4,cardLength + 4);
    for (var i = 0; i < cardBuffer.length; i+=10) {
      RFIDSocketModel rfidSocketModel = RFIDSocketModel();
      String a = Hex.encode(cardBuffer[i]);
      if (a.length == 1) {
        a = '0'+a;
      }
      String b = Hex.encode(cardBuffer[i+1]);
      if (b.length == 1) {
        b = '0'+b;
      }
      String c = Hex.encode(cardBuffer[i+2]);
      if (c.length == 1) {
        c = '0'+c;
      }
      rfidSocketModel.rfidId = Hex.decode(a + b + c);
      rfidSocketModel.status = Hex.decode(Hex.encode(cardBuffer[i + 3]));

      if (warningTypes == '失联' ) {
        
        rfidSocketModel.warningType ='失联报警';

      } else {
        Uint8List u= Uint8List.fromList([rfidSocketModel.status]);
        if ( u[0]&0x4F == 0x4F) {
          rfidSocketModel.warningType = '移动报警';
        } 
        if ( u[0]&0x80 == 0x80) {
          rfidSocketModel.warningType = rfidSocketModel.warningType + ',欠电报警';
        } 
      }
      if(timeStr.length> 0) { // 极光的时间  需要 - 8小时
        rfidSocketModel.timeStr = formatDate(DateTime.parse(timeStr).subtract(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
      } else{
        rfidSocketModel.timeStr = DateTime.now().subtract(new Duration(hours: 8)).toIso8601String();
      }
      rfidSocketModel.isJpush = isJpush;
      rfidList.add(rfidSocketModel);
    }
    
    setWarningListByRFID(context);
    // notifyListeners();
  }

  // 给 rfid 报警的 list增加至列表
  setWarningListByRFID( BuildContext context) {

    List<Exhibits> exhibitsList = Provide.value<MainPageProvide>(context).allExhibitsList;
    for (RFIDSocketModel item in rfidList) {
      for (Exhibits e in exhibitsList) {
        if (item.rfidId == e.rfidId) {
          Exhibits exhibits = _getExhibitsModel(e);
          exhibits.warningType = item.warningType;
          exhibits.timeStr = item.timeStr;
          exhibits.isJpush = item.isJpush;
          //写限制时间 同一个卡号 5秒后加入
          warningListByRFID.add(exhibits);
          continue;
        }
      }
    }
    // Provide.value<SocketNotifyProvide>(context).setWarningListByAll(context);
    notifyListeners();
  }

  // 从报警记录中获取所有的报警 并显示到状态
  setWarningListByAll(BuildContext context) async {
    List warningList = Provide.value<WarningManageProvide>(context).warningList;
    List<Exhibits> exhibitsList = Provide.value<MainPageProvide>(context).allExhibitsList;
    warningListByRFID = [];

    List<Exhibits> tempList = [];

    // warningListByRFID 所有的报警记录拿完后   和本地持久化存储的数据（已确认过的） 做对比
    //获取本地持久化的数据  是已确认过的报警
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> sureWarningList =  prefs.getStringList('SureWarningList');
    List<Exhibits> sureExhibits = [];
    if (sureWarningList != null) {
      for (var strCode in sureWarningList) {
        Exhibits e = new Exhibits();
        var json = jsonDecode(strCode);
        e.exhibitsId = json['exhibitsId'];
        e.rfidId = int.parse(json['rfidId']);
        e.timeStr = json['timeStr'];
        sureExhibits.add(e);
      }
    }
    for(Warning item in warningList) {
      for (Exhibits e in exhibitsList) {
        if (item.rfidId == e.rfidId) { // 如果报警的标签存在于  展馆的标签内
          //先对这个新属性进行一次赋值   
          Exhibits exhibits = _getExhibitsModel(e);
          // exhibits = 
          exhibits.timeStr = item.beginTime;
          if (item.comment.length > 0) {
            exhibits.warningType = '失联报警';
          }  else{
            String typeStr = item.type.substring(item.type.length -2, item.type.length);
            Uint8List u = Uint8List.fromList([_hexToInt(typeStr)]);
            if ( u[0]&0x4F == 0x4F) {
              exhibits.warningType = '移动报警';
            } 
            if ( u[0]&0x80 == 0x80) {
              exhibits.warningType = exhibits.warningType + ',欠电报警';
            } 
            if (item.comment == '失联') {
              exhibits.warningType = '失联报警';
            }
          }

          tempList.add(exhibits);
          continue;
        }
      }
    }
    int f = 0;
    for (var i = 0; i < tempList.length; i++) {
      if (sureExhibits.length== 0) {
        warningListByRFID.add(tempList[i]);
      }
      f = 0;
      for (var j = 0; j < sureExhibits.length; j++) {
          if (((tempList[i].timeStr == sureExhibits[j].timeStr) ||
           (formatDate(DateTime.parse(tempList[i].timeStr).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]) == sureExhibits[j].timeStr)||
           (formatDate(DateTime.parse(formatDate(DateTime.parse(tempList[i].timeStr).subtract(new Duration(seconds: 1)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).add(new Duration(hours: 8)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]) == sureExhibits[j].timeStr)) 
          &&
          (tempList[i].rfidId == sureExhibits[j].rfidId) &&
          (tempList[i].exhibitsId == sureExhibits[j].exhibitsId)) { //如果报警的标签  各项属性都符合在本地已确认的报警标签内
          // 是已确认过的报警  不作任何处理
          f = 1;
          break;
        } else {
          // 未确认过的报警
          f= 0;
        }
      }
      if ( f == 0) {
      warningListByRFID.add(tempList[i]);
      }
    }

    //修改 增加rfid   将所有已存在报警的地方生成pin
    createPinByWarningList(warningListByRFID);
    
    notifyListeners();
  }


  // 生成 Pin  根据现有的报警RFID数量生成
  createPinByWarningList(List<Exhibits> warningList) {
    pinList.list.clear();
    print('-----------version 1.2 新增输出内容');  
    print(warningList.length);
    for (Exhibits e in warningList) {
      Pin p = new Pin(e.rfidId, new Offset(e.mobileLeft, e.mobileTop), false);
      p.exhibitionId = e.exhibitionId;
      pinList.list.add(p);
    }

    notifyListeners();  
  }

  // 代入 展厅id   筛出仅限于此展厅的报警RFID
  selecPinByExhibition(int exhibitionId){

    // 初始化pinlist 或者是  清空 pinlist的数组  每次选择时都有此操作
    pinByExhibitionList.list.clear();
    
    for (Pin p in pinList.list) {
      if(p.exhibitionId == exhibitionId){
        Pin newP = p;
        pinByExhibitionList.list.add(newP);
      }
    }

    notifyListeners();
  }


  Exhibits _getExhibitsModel(Exhibits e) {
    Exhibits exhibits = new Exhibits();
    exhibits.exhibitionId = e.exhibitionId;
    exhibits.exhibitsId = e.exhibitsId;
    exhibits.exhibitsImg = e.exhibitsImg;
    exhibits.exhibitsName = e.exhibitsName;
    exhibits.exhibitsRecommend = e.exhibitsRecommend;
    exhibits.rfidId = e.rfidId;
    exhibits.showcaseId = e.showcaseId;
    exhibits.timeStr = e.timeStr;
    exhibits.mobileLeft = e.mobileLeft;
    exhibits.mobileTop = e.mobileTop;
    // exhibits.warningType = e.warningType;
    return exhibits;
  }


  setWarningLIstByHour(BuildContext context ,List<Warning> warningList) {
    List<Exhibits> exhibitsList = Provide.value<MainPageProvide>(context).allExhibitsList;
    for(Warning item in warningList) {
      for (Exhibits e in exhibitsList) {
        if (item.rfidId == e.rfidId) {
          e.timeStr = item.beginTime;
          e.warningType = item.type;
          warningListByRFID.add(e);
          continue;
        }
      }
    }
    notifyListeners();
  }


  checkRFIDListByExhibitionId(BuildContext context, int exhibitionId) {
    warningListByExhibition= [];
    for (Exhibits item in warningListByRFID) {
      if(item.exhibitionId == exhibitionId) {
        warningListByExhibition.add(item);
      }
    }

    notifyListeners();
  }

  // 减去当前rfid 被确认消警的list
  subtractWarningListByRFID(BuildContext context, Exhibits e) {

    if( warningListByExhibition.length !=0) {
      
      // warningListByRFID.remove(e);
      warningListByExhibition.remove(e);
      if(warningListByExhibition.length == 0) {
        warningListByRFID= [];
      }

      createPinByWarningList(warningListByRFID);
      notifyListeners();

    }

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
}



class RFIDSocketModel {
  int rfidId;
  int status;
  String warningType;

  String timeStr;

  bool isJpush;

  RFIDSocketModel({this.rfidId,this.status,this.warningType,this.timeStr,this.isJpush});
}

