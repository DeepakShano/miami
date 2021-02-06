class TaxiStats {
  String todayDate;
  String taxiID;
  int totalSeats;
  String name;
  List<TimingStat> startTimingList;
  List<TimingStat> returnTimingList;

  TaxiStats({
    this.returnTimingList,
    this.todayDate,
    this.taxiID,
    this.totalSeats,
    this.name,
    this.startTimingList,
  });

  TaxiStats.fromJson(Map<String, dynamic> json) {
    if (json['returnTimingList'] != null) {
      returnTimingList = new List<TimingStat>();
      json['returnTimingList'].forEach((v) {
        returnTimingList.add(TimingStat.fromJson(v));
      });
    }
    todayDate = json['todayDate'];
    taxiID = json['taxiID'];
    totalSeats = json['totalSeats'];
    name = json['name'];
    if (json['timingList'] != null) {
      startTimingList = new List<TimingStat>();
      json['timingList'].forEach((v) {
        startTimingList.add(new TimingStat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.returnTimingList != null) {
      data['returnTimingList'] =
          this.returnTimingList.map((v) => v.toJson()).toList();
    }
    data['todayDate'] = this.todayDate;
    data['taxiID'] = this.taxiID;
    data['totalSeats'] = this.totalSeats;
    data['name'] = this.name;
    if (this.startTimingList != null) {
      data['timingList'] = this.startTimingList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimingStat {
  int alreadyBooked;
  String time;

  TimingStat({this.alreadyBooked, this.time});

  TimingStat.fromJson(Map<String, dynamic> json) {
    alreadyBooked = json['alreadyBooked'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alreadyBooked'] = this.alreadyBooked;
    data['time'] = this.time;
    return data;
  }
}
