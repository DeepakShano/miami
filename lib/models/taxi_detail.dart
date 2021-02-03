class TaxiDetail {
  String id;
  int totalSeats;
  String ticketPrice;
  List<String> weekEndStartTiming;
  String name;
  List<String> weekDayStartTiming;
  List<String> weekEndReturnTiming;
  List<String> weekDayReturnTiming;

  TaxiDetail({
    this.id,
    this.totalSeats,
    this.ticketPrice,
    this.weekEndStartTiming,
    this.name,
    this.weekDayStartTiming,
    this.weekEndReturnTiming,
    this.weekDayReturnTiming,
  });

  TaxiDetail.fromJson(Map<String, dynamic> json) {
    totalSeats = json['TotalSeats'];
    ticketPrice = json['ticketPrice'];
    weekEndStartTiming = json['weekEndStartTiming'].cast<String>();
    name = json['name'];
    weekDayStartTiming = json['weekDayStartTiming'].cast<String>();
    weekEndReturnTiming = json['weekEndReturnTiming'].cast<String>();
    weekDayReturnTiming = json['weekDayReturnTiming'].cast<String>();
    id = json['ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TotalSeats'] = this.totalSeats;
    data['ticketPrice'] = this.ticketPrice;
    data['weekEndStartTiming'] = this.weekEndStartTiming;
    data['name'] = this.name;
    data['weekDayStartTiming'] = this.weekDayStartTiming;
    data['weekEndReturnTiming'] = this.weekEndReturnTiming;
    data['weekDayReturnTiming'] = this.weekDayReturnTiming;
    data['ID'] = this.id;
    return data;
  }
}
