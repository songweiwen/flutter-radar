class ServersModel {
  int status;
  String message;
  List<Servers> data;
  String timestamp;

  ServersModel({this.status, this.message, this.data, this.timestamp});

  ServersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Servers>();
      json['data'].forEach((v) {
        data.add(new Servers.fromJson(v));
      });
    }
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Servers {
  int id;
  String serversTime;
  String serversDescribe;

  Servers({this.id, this.serversTime, this.serversDescribe});

  Servers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serversTime = json['servers_time'];
    serversDescribe = json['servers_describe'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['servers_time'] = this.serversTime;
    data['servers_describe'] = this.serversDescribe;
    return data;
  }
}