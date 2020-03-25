class HostModel {
  int status;
  String message;
  List<Host> data;
  String timestamp;

  HostModel({this.status, this.message, this.data, this.timestamp});

  HostModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Host>();
      json['data'].forEach((v) {
        data.add(new Host.fromJson(v));
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

class Host {
  int hostId;
  String hostState;
  String hostElectric;
  int exhibitionId;
  String updateTime;
  String hostRecommend;

  bool isWarning;

  Host(
      {this.hostId,
      this.hostState,
      this.hostElectric,
      this.exhibitionId,
      this.updateTime,
      this.hostRecommend,
      this.isWarning});

  Host.fromJson(Map<String, dynamic> json) {
    hostId = json['hostId'];
    hostState = json['hostState'];
    hostElectric = json['hostElectric'];
    exhibitionId = json['exhibitionId'];
    updateTime = json['updateTime'];
    hostRecommend = json['hostRecommend'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hostId'] = this.hostId;
    data['hostState'] = this.hostState;
    data['hostElectric'] = this.hostElectric;
    data['exhibitionId'] = this.exhibitionId;
    data['updateTime'] = this.updateTime;
    data['hostRecommend'] = this.hostRecommend;
    return data;
  }
}