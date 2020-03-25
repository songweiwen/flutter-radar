class WarningModel {
  int status;
  String message;
  List<Warning> data;
  String timestamp;

  WarningModel({this.status, this.message, this.data, this.timestamp});

  WarningModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Warning>();
      json['data'].forEach((v) {
        data.add(new Warning.fromJson(v));
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

class Warning {
  int rfidId;
  String beginTime;
  int showcaseId;
  int exhibitionId;
  String exhibitsId;
  String type;
  Null userid;
  String comment;
  int verification;
  Null endTime;
  String exhibitsRecommend;
  String exhibitsName;

  Warning(
      {this.rfidId,
      this.beginTime,
      this.showcaseId,
      this.exhibitionId,
      this.exhibitsId,
      this.type,
      this.userid,
      this.comment,
      this.verification,
      this.endTime,
      this.exhibitsRecommend,
      this.exhibitsName});

  Warning.fromJson(Map<String, dynamic> json) {
    rfidId = json['rfidId'];
    beginTime = json['beginTime'];
    showcaseId = json['showcaseId'];
    exhibitionId = json['exhibitionId'];
    exhibitsId = json['exhibitsId'];
    type = json['type'];
    userid = json['userid'];
    comment = json['comment'];
    verification = json['verification'];
    endTime = json['endTime'];
    exhibitsRecommend = json['exhibitsRecommend'];
    exhibitsName = json['exhibitsName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rfidId'] = this.rfidId;
    data['beginTime'] = this.beginTime;
    data['showcaseId'] = this.showcaseId;
    data['exhibitionId'] = this.exhibitionId;
    data['exhibitsId'] = this.exhibitsId;
    data['type'] = this.type;
    data['userid'] = this.userid;
    data['comment'] = this.comment;
    data['verification'] = this.verification;
    data['endTime'] = this.endTime;
    data['exhibitsRecommend'] = this.exhibitsRecommend;
    data['exhibitsName'] = this.exhibitsName;
    return data;
  }
}