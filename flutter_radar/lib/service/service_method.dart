import 'package:dio/dio.dart';
import 'package:flutter_radar/config/appSetting.dart';
import 'package:flutter_radar/config/service_url.dart';
import 'package:shared_preferences/shared_preferences.dart';


//通用请求框架
Future request(url,{formData})async{
  try {
    
    Response response;
    Dio dio = new Dio();
    // dio.options.contentType = ContentType.parse("application/json;charset=UTF-8") as String;
    dio.options.responseType = ResponseType.plain;
    if (formData == null) {
      response = await dio.post(servicePath[url]);
    } else {
      response = await dio.post(servicePath[url],queryParameters: formData);
    }

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(server_error);
    }

  } catch (e) {
    return print('错误：=======>${e}');
  }
}

//获取首页 展馆信息方法
Future getMainPageContent() async{
  try {
    Response response;
    Dio dio = new Dio();
    // dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded") as String;
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['mainPage']);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}

//获取报警记录 信息方法
Future getWarningMangeContent() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name = prefs.get('userName');
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['warningManagePage'],queryParameters: {'username':name});
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}

//获取报警记录 1小时内 
Future getWarningListByHours() async {
    try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['warningListByHour']);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}

//获取展馆内文物信息方法
Future getExhibtsByExhibitionId({data}) async {
  try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['exhibitsPage'],queryParameters: data);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}

// 获取临展主机信息
Future getHost({data}) async {
  try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['hostPage'] ,queryParameters: data);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}


// 获取当前展馆的所有rfid
Future getRFIDByExhibition({data}) async {
    try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['exhibitsAll'],queryParameters: data);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}


// 查询当前临展主机的设备状态
Future getHostState(Map<String,dynamic> data) async {

  try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['checkHostState'],queryParameters: data);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}


// 请求获取手机验证码
Future getPhoneVerCode(Map<String,dynamic> data) async {
    try {
      Response response;
      Dio dio = new Dio();
      dio.options.responseType = ResponseType.plain;
      response = await dio.get(servicePath['getVerCode'],queryParameters: data);
      if(response.statusCode==200){
        return response.data;
      }else{
        throw Exception(server_error);
      }
    } catch (e) {
      return print('错误：=======>${e}');
    }
}

// 注销手机极光推送
Future exitJpush(Map<String,dynamic> data) async {
    try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.post(servicePath['exitJpush'],queryParameters: data);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}

// 获取当前用户推送状态
Future getUserPushState(Map<String,dynamic> data) async {
    try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['checkPush'],queryParameters: data);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}


//获取服务器情况
Future getServersStatus() async {
  try {
    Response response;
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.plain;
    response = await dio.get(servicePath['checkServers']);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception(server_error);
    }
  } catch (e) {
    return print('错误：=======>${e}');
  }
}
