class MainModel {
  int status;
  String message;
  List<Exhibition> data;
  String timestamp;

  MainModel({this.status, this.message, this.data, this.timestamp});

  MainModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Exhibition>();
      json['data'].forEach((v) {
        data.add(new Exhibition.fromJson(v));
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

class Exhibition {
  int exhibitionId;
  String exhibitionName;
  String exhibitionImg;
  String exhibitionRecommend;
  String areaName;
  String exhibitionAreaName;

  Exhibition(
      {this.exhibitionId,
      this.exhibitionName,
      this.exhibitionImg,
      this.exhibitionRecommend,
      this.areaName,
      this.exhibitionAreaName});

  Exhibition.fromJson(Map<String, dynamic> json) {
    exhibitionId = json['exhibitionId'];
    exhibitionName = json['exhibitionName'];
    exhibitionImg = json['exhibitionImg'];
    exhibitionRecommend = json['exhibitionRecommend'];
    areaName = json['areaName'];
    exhibitionAreaName = json['exhibitionAreaName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['exhibitionId'] = this.exhibitionId;
    data['exhibitionName'] = this.exhibitionName;
    data['exhibitionImg'] = this.exhibitionImg;
    data['exhibitionRecommend'] = this.exhibitionRecommend;
    data['areaName'] = this.areaName;
    data['exhibitionAreaName'] = this.exhibitionAreaName;
    return data;
  }
}