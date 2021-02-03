/// Model class for User
class AppUser {
  String phone;
  String userPin;
  String userType;
  String status;
  String name;
  String enrollDate;
  String userID;
  String fcmToken;
  String email;

  AppUser({
    this.phone,
    this.userPin,
    this.userType,
    this.status,
    this.name,
    this.enrollDate,
    this.userID,
    this.fcmToken,
    this.email,
  });

  AppUser.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    userPin = json['userPin'];
    userType = json['userType'];
    status = json['status'];
    name = json['name'];
    enrollDate = json['enrollDate'];
    userID = json['userID'];
    fcmToken = json['fcmToken'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['userPin'] = this.userPin;
    data['userType'] = this.userType;
    data['status'] = this.status;
    data['name'] = this.name;
    data['enrollDate'] = this.enrollDate;
    data['userID'] = this.userID;
    data['fcmToken'] = this.fcmToken;
    data['email'] = this.email;
    return data;
  }
}
