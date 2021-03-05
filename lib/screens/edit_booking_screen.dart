import 'package:flutter/material.dart';
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
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.booking.customerName;
    _phoneController.text = widget.booking.customerPhone;
    _emailController.text = widget.booking.email;
    _minorCountController.text = widget.booking.minor;
    _adultCountController.text = widget.booking.adult;
    _departureTimeController.text = widget.booking.tripStartTime;
    _returnTimeController.text = widget.booking.tripReturnTime;

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
                  child: Text('Update'),
                  onPressed: () {
                    _onPressPrimaryBtn(context);
                  },
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
            controller: _departureTimeController,
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
        ],
      ),
    );
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
    List<String> timingsList =
        isWeekend ? taxi.weekEndStartTiming : taxi.weekDayStartTiming;

    AlertDialog alert = AlertDialog(
      title: Text("Select Departing Time BS"),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: timingsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              timingsList.elementAt(index),
            ),
            onTap: () {
              _departureTimeController.text = timingsList.elementAt(index);
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
    List<String> timingsList =
        isWeekend ? taxi.weekEndReturnTiming : taxi.weekDayReturnTiming;

    AlertDialog alert = AlertDialog(
      title: Text("Select Departing Time MB"),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: timingsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              timingsList.elementAt(index),
            ),
            onTap: () {
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

    Booking oldBooking = Booking.fromRealJson(widget.booking.toRealJson());

    widget.booking.customerName = _nameController.text;
    widget.booking.customerPhone = _phoneController.text;
    widget.booking.email = _emailController.text;
    widget.booking.tripStartTime = _departureTimeController.text;
    widget.booking.tripReturnTime = _returnTimeController.text;
    widget.booking.adult = _adultCountController.text;
    widget.booking.minor = _minorCountController.text;

    bool hasTripTimingChanged =
        oldBooking.tripReturnTime != widget.booking.tripReturnTime ||
            oldBooking.tripStartTime != widget.booking.tripReturnTime;

    bool hasMinorAdultCountChanged = oldBooking.minor != widget.booking.minor ||
        oldBooking.adult != widget.booking.adult;

    List<TaxiStats> taxiStats = context.read<TaxiProvider>().taxiStats;
    TaxiStats taxiStat = taxiStats?.firstWhere(
      (e) => e.taxiID == widget.booking.taxiID,
      orElse: () => null,
    );

    if (hasTripTimingChanged) {
      TimingStat oldStartTimingStat = taxiStat.startTimingList
          .firstWhere((e) => e.time == oldBooking.tripStartTime);
      TimingStat oldReturnTimingStat = taxiStat.returnTimingList
          .firstWhere((e) => e.time == oldBooking.tripReturnTime);
      oldStartTimingStat.alreadyBooked -=
          int.parse(oldBooking.adult) + int.parse(oldBooking.minor);
      oldReturnTimingStat.alreadyBooked -=
          int.parse(oldBooking.adult) + int.parse(oldBooking.minor);

      TimingStat newStartTimingStat = taxiStat.startTimingList
          .firstWhere((e) => e.time == widget.booking.tripStartTime);
      TimingStat newReturnTimingStat = taxiStat.returnTimingList
          .firstWhere((e) => e.time == widget.booking.tripReturnTime);
      newStartTimingStat.alreadyBooked +=
          int.parse(widget.booking.adult) + int.parse(widget.booking.minor);
      newReturnTimingStat.alreadyBooked +=
          int.parse(widget.booking.adult) + int.parse(widget.booking.minor);
    } else if (hasMinorAdultCountChanged) {
      int adultChange =
          int.parse(widget.booking.adult) - int.parse(oldBooking.adult);
      int minorChange =
          int.parse(widget.booking.minor) - int.parse(oldBooking.minor);

      TimingStat startTimingStat = taxiStat.startTimingList
          .firstWhere((e) => e.time == oldBooking.tripStartTime);
      TimingStat returnTimingStat = taxiStat.returnTimingList
          .firstWhere((e) => e.time == oldBooking.tripReturnTime);
      startTimingStat.alreadyBooked += adultChange + minorChange;
      returnTimingStat.alreadyBooked += adultChange + minorChange;
    }

    // Update bookings
    String ticketId = await FirestoreDBService.updateBooking(
      widget.booking.ticketID,
      widget.booking,
      taxiStat,
    );

    Navigator.pop(context);
  }
}
