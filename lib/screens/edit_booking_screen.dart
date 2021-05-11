import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/services/database_service.dart';

import '../global.dart';

class EditBookingFormScreen extends StatefulWidget {
  final Booking booking;

  EditBookingFormScreen({
    Key key,
    @required this.booking,
  }) : super(key: key);

  @override
  _EditBookingFormScreenState createState() => _EditBookingFormScreenState();
}

class _EditBookingFormScreenState extends State<EditBookingFormScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adultCountController = TextEditingController();
  final TextEditingController _minorCountController = TextEditingController();
  final TextEditingController _dptTimeController = TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool isBtnLoading = false;

  @override
  void initState() {
    _nameController.text = widget.booking.customerName;
    _phoneController.text = widget.booking.customerPhone;
    _emailController.text = widget.booking.email;
    _minorCountController.text = widget.booking.minor;
    _adultCountController.text = widget.booking.adult;
    _dptTimeController.text = widget.booking.tripStartTime;
    _returnTimeController.text = widget.booking.tripReturnTime;
    _commentController.text = widget.booking.comment;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Booking'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              form(context),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  child: isBtnLoading
                      ? CircularProgressIndicator()
                      : Text('Update'),
                  onPressed:
                      isBtnLoading ? null : () => _onPressPrimaryBtn(context),
                  textColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget form(BuildContext context) {
    final node = FocusScope.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Full Name',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Full Name',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            'Customer Phone Number',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
            validator: (value) {
              if (!isEmailPhoneValid()) {
                return 'Both email and phone number cannot be empty';
              }

              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            'Customer Email',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onEditingComplete: () => node.unfocus(),
            validator: (value) {
              if (value.isNotEmpty) {
                if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                  return 'Enter a valid email address';
                }
              }

              if (!isEmailPhoneValid()) {
                return 'Both email and phone number cannot be empty';
              }

              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            'Departing Time BS',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _dptTimeController,
            keyboardType: TextInputType.datetime,
            enabled: true,
            readOnly: true,
            onTap: () {
              _openDepartureDialog();
            },
            decoration: InputDecoration(
              hintText: '00:00 AM',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onEditingComplete: () => node.unfocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            'Departing Time MB',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _returnTimeController,
            keyboardType: TextInputType.datetime,
            enabled: true,
            readOnly: true,
            onTap: () {
              _openReturnDialog();
            },
            decoration: InputDecoration(
              hintText: '00:00 AM',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adult(s)',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _adultCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => node.unfocus(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minor(s)',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _minorCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => node.unfocus(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Comment',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _commentController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Comments',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Future<String> validateDepartureTextField() async {
    String time = _dptTimeController.text;

    TaxiStats taxiStat = await FirestoreDBService.getTaxiStats(
      widget.booking.taxiID,
      DateFormat('ddMMMyyy').parse(widget.booking.bookingDate),
    );

    TimingStat matchingTimeStat = (widget.booking.startDeparting
            ? taxiStat.startTimingList
            : taxiStat.returnTimingList)
        .firstWhere((i) => i.time == time, orElse: () => null);

    return matchingTimeStat == null ? 'Select a valid departure time' : null;
  }

  Future<String> validateReturnTextField() async {
    String time = _returnTimeController.text;

    TaxiStats taxiStat = await FirestoreDBService.getTaxiStats(
      widget.booking.taxiID,
      DateFormat('ddMMMyyy').parse(widget.booking.bookingDate),
    );

    TimingStat matchingTimeStat = (widget.booking.startDeparting
            ? taxiStat.returnTimingList
            : taxiStat.startTimingList)
        .firstWhere((i) => i.time == time, orElse: () => null);

    return matchingTimeStat == null ? 'Select a valid return time' : null;
  }

  void _openDepartureDialog() {
    List<TaxiDetail> taxis = context.read<TaxiProvider>().taxis;
    TaxiDetail taxi = taxis.firstWhere(
      (element) => element.id == widget.booking.taxiID,
      orElse: () => null,
    );

    if (taxi == null) {
      logger.e('Some error in opening dialog');
      return;
    }

    bool isWeekend =
        [6, 7].contains(widget.booking.bookingDateTimeStamp.weekday);

    List<String> timingsList;
    if (widget.booking.startDeparting) {
      timingsList =
          isWeekend ? taxi.weekEndStartTiming : taxi.weekDayStartTiming;
    } else {
      timingsList =
          isWeekend ? taxi.weekEndReturnTiming : taxi.weekDayReturnTiming;
    }

    AlertDialog alert = AlertDialog(
      title: Text("Select Departing Time BS"),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: timingsList.length,
        itemBuilder: (context, index) {
          String timingStr = timingsList.elementAt(index);
          bool canSelect = true;

          DateTime now = DateTime.now();
          DateTime nextDateStart = DateTime(now.year, now.month, now.day);

          // If booking is of today. Hide/Untappable timings that are in past.
          if (widget.booking.bookingDateTimeStamp.difference(nextDateStart) <
              Duration(days: 1))
            try {
              int h = int.parse(timingStr.split(':').first);
              int m = int.parse(timingStr.split(':')[1].substring(0, 2));
              String meridian = timingStr.split(':')[1].substring(3, 5);

              if (meridian.toLowerCase() == 'pm' && h != 12) {
                h = h + 12;
              }

              TimeOfDay i = TimeOfDay(hour: h, minute: m);

              logger.d(i.toString());

              canSelect = i.compareTo(TimeOfDay.now()) == -1 ? false : true;
            } catch (e) {
              logger.e(e);
            }

          return ListTile(
            enabled: canSelect,
            title: Text(
              timingsList.elementAt(index),
            ),
            onTap: !canSelect
                ? null
                : () {
                    _dptTimeController.text = timingsList.elementAt(index);
                    Navigator.pop(context);
                  },
          );
        },
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _openReturnDialog() {
    List<TaxiDetail> taxis = context.read<TaxiProvider>().taxis;
    TaxiDetail taxi = taxis.firstWhere(
      (element) => element.id == widget.booking.taxiID,
      orElse: () => null,
    );

    if (taxi == null) {
      logger.e('Some error in opening dialog');
      return;
    }

    bool isWeekend =
        [6, 7].contains(widget.booking.bookingDateTimeStamp.weekday);
    List<String> timingsList;
    if (widget.booking.startDeparting) {
      timingsList =
          isWeekend ? taxi.weekEndReturnTiming : taxi.weekDayReturnTiming;
    } else {
      timingsList =
          isWeekend ? taxi.weekEndStartTiming : taxi.weekDayStartTiming;
    }

    AlertDialog alert = AlertDialog(
      title: Text("Select Departing Time MB"),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: timingsList.length,
        itemBuilder: (context, index) {
          String timingStr = timingsList.elementAt(index);
          bool canSelect = true;

          DateTime now = DateTime.now();
          DateTime nextDateStart = DateTime(now.year, now.month, now.day);

          // If booking is of today. Hide/Untappable timings that are in past.
          if (widget.booking.bookingDateTimeStamp.difference(nextDateStart) <
              Duration(days: 1))
            try {
              int h = int.parse(timingStr.split(':').first);
              int m = int.parse(timingStr.split(':')[1].substring(0, 2));
              String meridian = timingStr.split(':')[1].substring(3, 5);

              if (meridian.toLowerCase() == 'pm' && h != 12) {
                h = h + 12;
              }

              TimeOfDay i = TimeOfDay(hour: h, minute: m);

              logger.d(i.toString());

              canSelect = i.compareTo(TimeOfDay.now()) == -1 ? false : true;
            } catch (e) {
              logger.e(e);
            }

          return ListTile(
            enabled: canSelect,
            title: Text(
              timingsList.elementAt(index),
            ),
            onTap: !canSelect
                ? null
                : () {
                    _returnTimeController.text = timingsList.elementAt(index);
                    Navigator.pop(context);
                  },
          );
        },
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool isEmailPhoneValid() {
    return _emailController.text.isNotEmpty || _phoneController.text.isNotEmpty;
  }

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      logger.d('Invalid form submission');
      return;
    }

    String departureTimeFieldError = await validateDepartureTextField();
    String returnTimeFieldError = await validateReturnTextField();

    if (departureTimeFieldError != null) {
      return _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(departureTimeFieldError),
        backgroundColor: Theme.of(context).errorColor,
      ));
    } else if (returnTimeFieldError != null) {
      return _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(returnTimeFieldError),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }

    Booking oldBooking = Booking.fromRealJson(widget.booking.toRealJson());
    Booking newBooking = Booking.fromRealJson(widget.booking.toRealJson());

    newBooking.customerName = _nameController.text;
    newBooking.customerPhone = _phoneController.text;
    newBooking.email = _emailController.text;
    newBooking.tripStartTime = _dptTimeController.text;
    newBooking.tripReturnTime = _returnTimeController.text;
    newBooking.adult = _adultCountController.text;
    newBooking.minor = _minorCountController.text;
    newBooking.comment = _commentController.text;

    bool hasMinorAdultCountChanged = oldBooking.minor != newBooking.minor ||
        oldBooking.adult != newBooking.adult;

    TaxiStats taxiStat = await FirestoreDBService.getTaxiStats(
      newBooking.taxiID,
      DateFormat('ddMMMyyy').parse(newBooking.bookingDate),
    );

    logger.d('taxiStat: ${taxiStat.toJson()}');

    logger.d(
        'hasTripTimingChanged(oldBooking, newBooking): ${hasTripTimingChanged(oldBooking, newBooking)}');
    logger.d('hasMinorAdultCountChanged: ${hasMinorAdultCountChanged}');

    if (hasTripTimingChanged(oldBooking, newBooking)) {
      // TODO: Could improve code. Very unreadable. Very "complex".
      TimingStat oldStartTimingStat = (oldBooking.startDeparting
              ? taxiStat.startTimingList
              : taxiStat.returnTimingList)
          .firstWhere((e) => e.time == oldBooking.tripStartTime);
      TimingStat oldReturnTimingStat = (oldBooking.startDeparting
              ? taxiStat.returnTimingList
              : taxiStat.startTimingList)
          .firstWhere((e) => e.time == oldBooking.tripReturnTime);
      oldStartTimingStat.alreadyBooked -=
          int.parse(oldBooking.adult) + int.parse(oldBooking.minor);
      oldReturnTimingStat.alreadyBooked -=
          int.parse(oldBooking.adult) + int.parse(oldBooking.minor);

      TimingStat newStartTimingStat = (oldBooking.startDeparting
              ? taxiStat.startTimingList
              : taxiStat.returnTimingList)
          .firstWhere((e) => e.time == newBooking.tripStartTime);
      TimingStat newReturnTimingStat = (oldBooking.startDeparting
              ? taxiStat.returnTimingList
              : taxiStat.startTimingList)
          .firstWhere((e) => e.time == newBooking.tripReturnTime);
      newStartTimingStat.alreadyBooked +=
          int.parse(newBooking.adult) + int.parse(newBooking.minor);
      newReturnTimingStat.alreadyBooked +=
          int.parse(newBooking.adult) + int.parse(newBooking.minor);
    } else if (hasMinorAdultCountChanged) {
      int adultChange =
          int.parse(newBooking.adult) - int.parse(oldBooking.adult);
      int minorChange =
          int.parse(newBooking.minor) - int.parse(oldBooking.minor);

      logger.d('adultChange: $adultChange');
      logger.d('minorChange: $minorChange');

      TimingStat startTimingStat = (oldBooking.startDeparting
              ? taxiStat.startTimingList
              : taxiStat.returnTimingList)
          .firstWhere((e) => e.time == oldBooking.tripStartTime);
      TimingStat returnTimingStat = (oldBooking.startDeparting
              ? taxiStat.returnTimingList
              : taxiStat.startTimingList)
          .firstWhere((e) => e.time == oldBooking.tripReturnTime);
      startTimingStat.alreadyBooked += adultChange + minorChange;
      returnTimingStat.alreadyBooked += adultChange + minorChange;

      logger.d(
          'startTimingStat.alreadyBooked : ${startTimingStat.alreadyBooked}');
      logger.d(
          'returnTimingStat.alreadyBooked  : ${returnTimingStat.alreadyBooked}');
    }

    // Update bookings
    setState(() => isBtnLoading = true);
    logger.d('Update booking: ${newBooking.toRealJson()}');
    logger.d('Update taxi stats: ${taxiStat.toJson()}');
    String ticketId = await FirestoreDBService.updateBooking(
      newBooking.ticketID,
      newBooking,
      taxiStat,
    );
    setState(() => isBtnLoading = false);

    Navigator.pop(context);
  }

  bool hasTripTimingChanged(Booking oldBooking, Booking newBooking) {
    return oldBooking.tripReturnTime != newBooking.tripReturnTime ||
        oldBooking.tripStartTime != newBooking.tripStartTime;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  /// Returns -1 if [other] is bigger.
  int compareTo(TimeOfDay other) {
    if (this.hour < other.hour) return -1;
    if (this.hour > other.hour) return 1;
    if (this.minute < other.minute) return -1;
    if (this.minute > other.minute) return 1;
    return 0;
  }
}
