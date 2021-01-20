class AdminMessage {
  String messageID;
  String messageDate;
  String message;

  AdminMessage({this.messageID, this.messageDate, this.message});

  AdminMessage.fromJson(Map<String, dynamic> json) {
    messageID = json['messageID'];
    messageDate = json['messageDate'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = this.messageID;
    data['messageDate'] = this.messageDate;
    data['message'] = this.message;
    return data;
  }
}