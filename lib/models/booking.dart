class Booking {
  String taxiID;
  String customerName;
  String status;
  String comment;
  String tripStartTime;
  String adult;
  DateTime bookingDateTimeStamp;
  String tripReturnTime;
  String email;
  String customerPhone;
  String agentName;
  String bookingAgentID;
  String minor;
  String bookingDate;
  String ticketID;

  Booking({
    this.taxiID,
    this.customerName,
    this.status,
    this.comment,
    this.tripStartTime,
    this.adult,
    this.bookingDateTimeStamp,
    this.tripReturnTime,
    this.email,
    this.customerPhone,
    this.agentName,
    this.bookingAgentID,
    this.minor,
    this.bookingDate,
    this.ticketID,
  });

  Booking.fromJson(Map<String, dynamic> json) {
    taxiID = json['taxiID'];
    customerName = json['customerName'];
    status = json['status'];
    comment = json['comment'];
    tripStartTime = json['tripStartTime'];
    adult = json['adult'];
    bookingDateTimeStamp = json['bookingDateTimeStamp'] == null
        ? null
        : DateTime.parse(json['bookingDateTimeStamp']);
    tripReturnTime = json['tripReturnTime'];
    email = json['email'];
    customerPhone = json['customePhone'];
    agentName = json['agentName'];
    bookingAgentID = json['bookingAgentID'];
    minor = json['minor'];
    bookingDate = json['bookingDate'];
    ticketID = json['ticketID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taxiID'] = this.taxiID;
    data['customerName'] = this.customerName;
    data['status'] = this.status;
    data['comment'] = this.comment;
    data['tripStartTime'] = this.tripStartTime;
    data['adult'] = this.adult;
    data['bookingDateTimeStamp'] = this.bookingDateTimeStamp;
    data['tripReturnTime'] = this.tripReturnTime;
    data['email'] = this.email;
    data['customePhone'] = this.customerPhone;
    data['agentName'] = this.agentName;
    data['bookingAgentID'] = this.bookingAgentID;
    data['minor'] = this.minor;
    data['bookingDate'] = this.bookingDate;
    data['ticketID'] = this.ticketID;
    return data;
  }
}
