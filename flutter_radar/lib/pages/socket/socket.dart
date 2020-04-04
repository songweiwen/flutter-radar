
import 'dart:io';
import 'dart:typed_data';
import 'package:convert_hex/convert_hex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/provide/socketNotify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crc16.dart';

/**  帧头用2个字节描述 */
const int headerByteLen = 2;
/** 信息长度用2个字节描述 */
const int msgByteLen = 2;
/** 源端口号用1个字节描述 */ 
const int sourcePortByteLen = 1;
/** 目标端口号用1个字节描述 */ 
const int targetPortByteLen = 1;
/** 功能号用1个字节描述 */ 
const int funcByteLen = 1;
/** CRC校验用2个字节描述 */
const int crcByteLen = 2;
/**  帧尾用2个字节描述 */
const int trailByteLen = 2;
/** 最小的消息长度 */
const int minMsgByteLen = headerByteLen + msgByteLen + sourcePortByteLen + targetPortByteLen
                        + funcByteLen + crcByteLen + trailByteLen;


class SocketNetWorkManager {

  /** 服务器ip */
  final String host;
  /** 服务器端口 */
  final int port;

  final BuildContext context;
  
  Socket socket;
  /** 缓存的网络数据，暂未处理（一般这里有数据，说明当前接收的数据不是一个完整的消息，需要等待其它数据的到来拼凑成一个完整的消息） */
  List<int> cacheDataInt = List<int>();
  
  SocketNetWorkManager(this.host,this.port,this.context);
  
  /**
   * 初始化连接服务器
   */
  void init() async{
    try {
      socket = await Socket.connect(host, port);  

      socket.listen(decodeHandle,
        onError: errorHandler,
        onDone: doneHandler,
        cancelOnError: false);
        print("连接socket成功！！！！！！！！！");
        Provide.value<SocketNotifyProvide>(context).setSocketStatus(1,"",null);
        Provide.value<SocketNotifyProvide>(context).sureHeartBest();//此时一定要给心跳重制
    } catch (e) {
      print("连接socket出现异常，e=${e.toString()}");
      Provide.value<SocketNotifyProvide>(context).setSocketStatus(3,"",null);
    }

  }
 
  /**
   * 解码处理方法
   * 处理服务器发过来的数据，注意，这里要处理粘包，这个data参数不一定是一个完整的包
   */
  void decodeHandle(newData){
    // cacheDataInt.clear();
    //拼凑当前最新未处理的网络数据
    cacheDataInt = List.from(cacheDataInt + newData);
    //缓存数据长度符合最小包长度才尝试解码
    while(cacheDataInt.length >= minMsgByteLen){
      
      // if(cacheDataInt.length > 3000) {
      //   cacheDataInt.clear();
      //   return;
      // }

      // 消息基本长度足够   判断是不是帧头
      if (cacheDataInt[0] == 0x28 && cacheDataInt[1] == 0x97) {
        
        int msgLen=0;
        if (cacheDataInt.length > 4) {
          //获取内容长度 
          msgLen = Hex.decode(Hex.encode(cacheDataInt[2]) + Hex.encode(cacheDataInt[3]));
          //数据长度小于消息长度，说明不是完整的数据，暂不处理
          // if(cacheDataInt.length < msgLen + msgByteLen){
          //   cacheDataInt.clear();
          //   return;
          // }
        }

        if (msgLen + 6 <= cacheDataInt.length) {
              //截取内容做crc校验
          Uint8List crcBuffer = Uint8List.fromList(cacheDataInt.sublist(2,headerByteLen + msgLen));
          int crc = Crc16.calcCrc16(crcBuffer, crcBuffer.length);
          String crcString = Hex.encode(crc);
          
          for (var i = 0; i  < 4 - crcString.length; i++) {
            crcString =  '0'+crcString;
          }

          if (_hexToInt(crcString.substring(0,2)) == cacheDataInt[headerByteLen+ msgLen] &&
              _hexToInt(crcString.substring(2,4)) == cacheDataInt[headerByteLen+ msgLen + 1]) {
              
            //crc 校验通过
            // 读取目标端口号 确定本条消息发自手机app
            if (cacheDataInt[5] == 0x03) { // 目标端口号显示为手机app
              //读取指令
              switch (cacheDataInt[6]) {
                case 0x02: //服务器应答 登陆成功
                  Provide.value<SocketNotifyProvide>(context).setSocketStatus(1,"",null);
                  //处理完成当前指令
                  cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
                  break;
                case 0x04: //标签报警 
                  //获取一下卡长度
                  int cardLength = Hex.decode(Hex.encode(cacheDataInt[9]) + Hex.encode(cacheDataInt[10]));
                  List<int> cardBuffer = cacheDataInt.sublist(7, 7+2+2+cardLength);
                  // Provide.value<SocketNotifyProvide>(context).setWarningSocketModel(cardBuffer, context ,'位移','');
                  Provide.value<SocketNotifyProvide>(context).setSocketStatus(1,"",null);
                  //处理完成当前指令
                  cacheDataInt.clear();
                  // cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
                  break;
                case 0x21: //标签失联
                  //获取一下卡长度
                  int cardLength = Hex.decode(Hex.encode(cacheDataInt[9]) + Hex.encode(cacheDataInt[10]));
                  List<int> cardBuffer = cacheDataInt.sublist(7, 7+2+2+cardLength);
                  // Provide.value<SocketNotifyProvide>(context).setWarningSocketModel(cardBuffer, context, '失联','');
                  // cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
                  Provide.value<SocketNotifyProvide>(context).setSocketStatus(1,"",null);
                  cacheDataInt.clear();
                  break;
                case 0x10: // 服务器心跳应答
                  print('收到服务器心跳的应答！');
                  Provide.value<SocketNotifyProvide>(context).sureHeartBest();
                  //处理完成当前指令
                  // cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
                  cacheDataInt.clear();
                  break;
                
                case 0x05: // 收到人工检测应答
                  int cardLength = Hex.decode(Hex.encode(cacheDataInt[2]) + Hex.encode(cacheDataInt[3]));
                  List<int> cardBuffer = cacheDataInt.sublist(2, 2 + cardLength);
                  Provide.value<SocketNotifyProvide>(context).setCheckRGSocketModel(cardBuffer, context, '人工检测');
                  //处理完成当前指令
                  cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
                  break;
                case 0x08: // 收到设备主动故障上报
                  int cardLength = Hex.decode(Hex.encode(cacheDataInt[2]) + Hex.encode(cacheDataInt[3]));
                  List<int> cardBuffer = cacheDataInt.sublist(2, 2 + cardLength);
                  Provide.value<SocketNotifyProvide>(context).setCheckRGSocketModel(cardBuffer, context,'设备上报');
                  //处理完成当前指令
                  cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
                  break;

                case 0x15:
                // 暂时对 回复数据做的处理
                  print('读取参数成功回执！');
                  int cardLength = Hex.decode(Hex.encode(cacheDataInt[2]) + Hex.encode(cacheDataInt[3]));
                  List<int> cardBuffer = cacheDataInt.sublist(2, 2 + cardLength);
                  Provide.value<SocketNotifyProvide>(context).setCheckReadHostParameter(cardBuffer, context,'读取参数');
                  cacheDataInt.clear();
                  break;
                
                case 0x12:
                  print('参数设置成功回执！');
                  Fluttertoast.showToast(
                    msg: "参数设置成功！",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                  cacheDataInt.clear();
                  break;
                default:
              }
              
            } else {
              // 不是发给手机app的数据包 后面如果粘着手机app的数据包
              cacheDataInt = cacheDataInt.sublist(headerByteLen+ msgLen + crcByteLen + trailByteLen,cacheDataInt.length);
            }
          } else {
            //crc 校验不通过  一条包
            // cacheDataInt = cacheDataInt.sublist(headerByteLen+msgLen+2,cacheDataInt.length);
            cacheDataInt.clear();
          }
        }
       
      } else {
        // 不是帧头  应丢弃1个字节的数据
        // cacheDataInt = cacheDataInt.sublist(cacheDataInt.length,cacheDataInt.length);
        cacheDataInt.clear();
      }
    }
  }


  /**
   * 发消息，指定消息号，pb对象可以为不传(例如发心跳包的时候)
   */
  void sendMsg(int msgCode){
    //序列化pb对象
    Uint8List pbBody;
    int pbLen = 0;
    //包头部分
    var header = ByteData(minMsgByteLen);
    header.setInt16(0, crcByteLen + pbLen);
    header.setInt16(msgByteLen, msgCode);
 
    //包头+pb组合成一个完整的数据包
    var msg = pbBody == null ? header.buffer.asUint8List() : header.buffer.asUint8List() + pbBody.buffer.asUint8List();
 
    //给服务器发消息
    try {
      socket.add(msg);
      print("给服务端发送消息，消息号=$msgCode");
    } catch (e) {
      print("send捕获异常：msgCode=${msgCode}，e=${e.toString()}");
    }
  }

  //发送socket 心跳包
  void sendHeart() async {
    Uint8List msgHeart;
    List<int> buffer = [0x28,0x97];
    List<int> body_buffer = [0x00, 0x0D, 0x03, 0x04, 0x09, 0x00, 0x01]; 
        SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') !=null) {
      
      String phoneNumber = prefs.getString('userName') + '0';// 后面补0
      if (phoneNumber.length == 12) {
        for (int i = 0; i < phoneNumber.length; i+=2) {
          body_buffer.add(_hexToInt(phoneNumber.substring(i,i+2)));
        }

        Uint8List crcbuffer = Uint8List.fromList(body_buffer);
        int crc = Crc16.calcCrc16(crcbuffer,crcbuffer.length);
        //准备crc校验
        String crcString = Hex.encode(crc);
        
        for (var i = crcString.length; i  < 4 ; i++) {
            crcString =  '0'+crcString;
        }

        if (crcString.length == 4) {
          for (int i = 0; i < crcString.length; i+=2) {
            body_buffer.add(_hexToInt(crcString.substring(i,i+2)));
          }
        }

        //数据拼接完毕
        buffer.addAll(body_buffer);
        buffer.add(0x28);
        buffer.add(0x98);//拼接帧尾
        msgHeart = Uint8List.fromList(buffer);
        // var msg = buffer as Uint8List;
        //给服务器发消息
        try {
          socket.add(msgHeart);
        } catch (e) {

        }
      }
    } else {
      //提示用户登陆
        Fluttertoast.showToast(
          msg: "请登陆账号以连接Tcp服务器！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
    }
  }

  //发送登陆socket服务器包
  void sendLogin() async{

    Uint8List msgLogin;
    List<int> buffer = [0x28,0x97];
    List<int> body_buffer = [0x00, 0x12, 0x03, 0x04, 0x01, 0x00, 0x01, 0x01]; 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') !=null) {
      
      String phoneNumber = prefs.getString('userName') + '0';// 后面补0
      if (phoneNumber.length == 12) {
        for (int i = 0; i < phoneNumber.length; i+=2) {
          body_buffer.add(_hexToInt(phoneNumber.substring(i,i+2)));
        }
        // 补密码 => 需要优化内容
        body_buffer.add(0x33);body_buffer.add(0x33);body_buffer.add(0x33);body_buffer.add(0x33);

        Uint8List crcbuffer = Uint8List.fromList(body_buffer);
        int crc = Crc16.calcCrc16(crcbuffer,crcbuffer.length);
        //准备crc校验
        String crcString = Hex.encode(crc);
        for (var i = crcString.length; i  < 4 ; i++) {
            crcString =  '0'+crcString;
        }
        
        if (crcString.length == 4) {
          for (int i = 0; i < crcString.length; i+=2) {
            body_buffer.add(_hexToInt(crcString.substring(i,i+2)));
          }
        }
        //数据拼接完毕
        buffer.addAll(body_buffer);
        buffer.add(0x28);
        buffer.add(0x98);//拼接帧尾
        msgLogin = Uint8List.fromList(buffer);
        // var msg = buffer as Uint8List;
        //给服务器发消息
        try {
          socket.add(msgLogin);
        } catch (e) {
          print('登录数据包发送失败。失败原因：${e}');
        }
      }
    } else {
      //提示用户登陆
        Fluttertoast.showToast(
          msg: "请登陆账号以连接Tcp服务器！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
    }
  }

// 手机发送人工检测
   void sendRGJC(String str) async{

    Uint8List msgLogin;
    List<int> buffer = [0x28,0x97];
    List<int> body_buffer = [0x00, 0x0D, 0x03, 0x01, 0x06]; 

    for (var i = str.length; i < 4; i++) {
      str = '0'+ str;
    }
    
    //拼接临展主机id号
    for (int i = 0; i < str.length; i+=2) {
          body_buffer.add(_hexToInt(str.substring(i,i+2)));
    }
    // body_buffer.add(_hexToInt(str));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') !=null) {
      
      String phoneNumber = prefs.getString('userName') + '0';// 后面补0
      if (phoneNumber.length == 12) {
        for (int i = 0; i < phoneNumber.length; i+=2) {
          body_buffer.add(_hexToInt(phoneNumber.substring(i,i+2)));
        }

        Uint8List crcbuffer = Uint8List.fromList(body_buffer);
        int crc = Crc16.calcCrc16(crcbuffer,crcbuffer.length);
        //准备crc校验
        String crcString = Hex.encode(crc);
        for (var i = crcString.length; i  < 4 ; i++) {
            crcString =  '0'+crcString;
        }
        
        if (crcString.length == 4) {
          for (int i = 0; i < crcString.length; i+=2) {
            body_buffer.add(_hexToInt(crcString.substring(i,i+2)));
          }
        }
        //数据拼接完毕
        buffer.addAll(body_buffer);
        buffer.add(0x28);
        buffer.add(0x98);//拼接帧尾
        msgLogin = Uint8List.fromList(buffer);
        // var msg = buffer as Uint8List;
        //给服务器发消息
        try {
          socket.add(msgLogin);
          print('人工检测已经发送！');
        } catch (e) {
          print('人工检测执行失败！！！失败原因：${e}');
        }
      }
    } else {
      //提示用户登陆
        Fluttertoast.showToast(
          msg: "请登陆账号以连接Tcp服务器！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
    }
  }

 
// 手机读取临展主机参数
  void sendReadHost(String str) async {

    Uint8List msgLogin;
    List<int> buffer = [0x28,0x97];
    List<int> body_buffer = [0x00, 0x0D, 0x03, 0x01, 0x11]; 

    for (var i = str.length; i < 4; i++) {
      str = '0'+ str;
    }
    
    //拼接临展主机id号
    for (int i = 0; i < str.length; i+=2) {
          body_buffer.add(_hexToInt(str.substring(i,i+2)));
    }
    // body_buffer.add(_hexToInt(str));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') !=null) {
      
      String phoneNumber = prefs.getString('userName') + '0';// 后面补0
      if (phoneNumber.length == 12) {
        for (int i = 0; i < phoneNumber.length; i+=2) {
          body_buffer.add(_hexToInt(phoneNumber.substring(i,i+2)));
        }

        Uint8List crcbuffer = Uint8List.fromList(body_buffer);
        int crc = Crc16.calcCrc16(crcbuffer,crcbuffer.length);
        //准备crc校验
        String crcString = Hex.encode(crc);
        for (var i = crcString.length; i  < 4 ; i++) {
            crcString =  '0'+crcString;
        }
        
        if (crcString.length == 4) {
          for (int i = 0; i < crcString.length; i+=2) {
            body_buffer.add(_hexToInt(crcString.substring(i,i+2)));
          }
        }
        //数据拼接完毕
        buffer.addAll(body_buffer);
        buffer.add(0x28);
        buffer.add(0x98);//拼接帧尾
        msgLogin = Uint8List.fromList(buffer);
        // var msg = buffer as Uint8List;
        //给服务器发消息
        try {
          socket.add(msgLogin);
          print('读取临展主机${str}已经发送！');
        } catch (e) {
          print('读取临展主机失败！！！失败原因：${e}');
        }
      }
    } else {
      //提示用户登陆
        Fluttertoast.showToast(
          msg: "请登陆账号以连接Tcp服务器！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
    }

  }


// 手机设置临展主机参数
  void sendSetHost(String str , dynamic data) async {

    Uint8List msgLogin;
    List<int> buffer = [0x28,0x97];
    List<int> body_buffer = [0x00, 0x11, 0x03, 0x01, 0x13]; 

    for (var i = str.length; i < 4; i++) {
      str = '0'+ str;
    }
    
    //拼接临展主机id号
    for (int i = 0; i < str.length; i+=2) {
          body_buffer.add(_hexToInt(str.substring(i,i+2)));
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') !=null) {
      
      String phoneNumber = prefs.getString('userName') + '0';// 后面补0
      if (phoneNumber.length == 12) {
        for (int i = 0; i < phoneNumber.length; i+=2) {
          body_buffer.add(_hexToInt(phoneNumber.substring(i,i+2)));
        }
        // 对设置的参数进行拼接
        body_buffer.add(_hexToInt(data['hostWarningC']));
        body_buffer.add(_hexToInt(data['hostWarningTotalC']));
        body_buffer.add(_hexToInt(data['rFIDWarningC']));
        body_buffer.add(_hexToInt(data['rFIDWarningTotalC']));

        Uint8List crcbuffer = Uint8List.fromList(body_buffer);
        int crc = Crc16.calcCrc16(crcbuffer,crcbuffer.length);
        //准备crc校验
        String crcString = Hex.encode(crc);
        for (var i = crcString.length; i  < 4 ; i++) {
            crcString =  '0'+crcString;
        }
        
        if (crcString.length == 4) {
          for (int i = 0; i < crcString.length; i+=2) {
            body_buffer.add(_hexToInt(crcString.substring(i,i+2)));
          }
        }
        //数据拼接完毕
        buffer.addAll(body_buffer);
        buffer.add(0x28);
        buffer.add(0x98);//拼接帧尾
        msgLogin = Uint8List.fromList(buffer);
        // var msg = buffer as Uint8List;
        //给服务器发消息
        try {
          socket.add(msgLogin);
          print('设置临展主机${str}已经发送！');
        } catch (e) {
          print('设置临展主机失败！！！失败原因：${e}');
        }
      }
    } else {
      //提示用户登陆
        Fluttertoast.showToast(
          msg: "请登陆账号以连接Tcp服务器！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
    }
  }



  void errorHandler(error, StackTrace trace){
    print("捕获socket异常信息：error=$error，trace=${trace.toString()}");
    socket.close();
    Provide.value<SocketNotifyProvide>(context).setSocketStatus(3,"",null);

  }
 
  void doneHandler(){ 
    // socket.close();
    socket.destroy();
    // Provide.value<SocketNotifyProvide>(context).setSocketStatus(3,"");
    // //断开链接 暂时处理方法  重连
    print("socket关闭处理");
    // init();
    // sendLogin();
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


