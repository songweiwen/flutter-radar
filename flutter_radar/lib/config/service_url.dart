
// const serviceUrl = 'http://www.dynercomm-radar.com:5000/';
// const serviceUrl = 'http://songweiwenceshi.oicp.io:53575/';
const serviceUrl = 'http://192.168.1.102:5000/';

// const socketUrl = '39.105.81.161';
const socketUrl = '192.168.1.102';

const servicePath ={
  'mainPage': serviceUrl+'main',//main 获取所有展 馆信息
  'warningManagePage' : serviceUrl+'warning',//warning 获取所有报警信息
  'exhibitsPage': serviceUrl + 'main/exhibts',// exhibts 获取所有展品信息
  'loginPage': serviceUrl + 'login', // 登录账号
  'smsPage' : serviceUrl + 'sms/updata', // 修改手机短信接收状态
  'hostPage' : serviceUrl + 'host',// 获取临展主机信息 b
  'exhibitsAll' : serviceUrl +'main/exhibtsAll',//获取展馆所有的RFID
  'warningListByHour' : serviceUrl +'warning/hour', // 获取展馆一小时内的报警记录消息
  'checkHostState' : serviceUrl + 'host/id', // host 状态查询
  'getVerCode' : serviceUrl + 'login/vercode',// 获取验证码
  'exitJpush' : serviceUrl + 'login/exit',// 退出极光推送
  'checkPush' : serviceUrl + 'login/checkpush', // 检查用户 推送设置状态
  'setJpush' : serviceUrl + 'login/setJpush',// 设置极光推送
  'checkServers': serviceUrl + 'login/checkservers',// 查询服务器状态
}; 