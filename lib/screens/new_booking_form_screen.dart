import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/models/newbooking.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/ticket_booked_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

import '../global.dart';

class NewBookingFormScreen extends StatefulWidget {
  final TaxiDetail taxidetails;
  final String selectedDepartTime;
  final String selectedReturnTime;
  bool isRoundTrip;

  NewBookingFormScreen({Key key,
    @required this.selectedDepartTime,
    @required this.selectedReturnTime,
    @required this.taxidetails,
    this.isRoundTrip})
      : super(key: key);

  @override
  _NewBookingFormScreenState createState() => _NewBookingFormScreenState();
}

class _NewBookingFormScreenState extends State<NewBookingFormScreen> {
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
  final TextEditingController _squareCodeController = TextEditingController();

  bool isBtnLoading = false;

  @override
  void initState() {
    if (widget.selectedDepartTime != null) {
      _dptTimeController.text = widget.selectedDepartTime;
    }

    if (widget.selectedReturnTime != null) {
      _returnTimeController.text = widget.selectedReturnTime;
    }

    _minorCountController.text = '0';
    _adultCountController.text = '0';

    if (DEBUG) {
      _nameController.text = 'Test';
      _phoneController.text = '9895952623';
      _emailController.text = 'a@a.com';
      _minorCountController.text = '1';
      _adultCountController.text = '1';
      _commentController.text = 'test test test';
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Booking'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              form(context),
              SizedBox(height: 20),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: RaisedButton(
                  child: isBtnLoading
                      ? CircularProgressIndicator()
                      : Text('Submit'),
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
          Center(
              child: RichText(
                text: TextSpan(
                  text: 'Ticket type :',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                        text: " ${widget.isRoundTrip
                            ? 'Round trip'
                            : 'One way'}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 16)),
                  ],
                ),
              )),
          SizedBox(height: 20),
          Text(
            'Customer Full Name',
            style: Theme
                .of(context)
                .textTheme
                .bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Full Name',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
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
            style: Theme
                .of(context)
                .textTheme
                .bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
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
            style: Theme
                .of(context)
                .textTheme
                .bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
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
            style: Theme
                .of(context)
                .textTheme
                .bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _dptTimeController,
            keyboardType: TextInputType.datetime,
            enabled: false,
            decoration: InputDecoration(
              hintText: '00:00 AM',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
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
          SizedBox(height: widget.selectedReturnTime.isNotEmpty ? 20 : 0),
          Visibility(
            visible: widget.selectedReturnTime.isNotEmpty,
            child: Text(
              'Departing Time MB',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyText2,
            ),
          ),
          SizedBox(height: widget.selectedReturnTime.isNotEmpty ? 10 : 0),
          Visibility(
            visible: widget.selectedReturnTime.isNotEmpty,
            child: TextFormField(
              controller: _returnTimeController,
              keyboardType: TextInputType.datetime,
              enabled: false,
              decoration: InputDecoration(
                hintText: '00:00 AM',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme
                        .of(context)
                        .primaryColor,
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText2,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _adultCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => node.unfocus(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field cannot be empty';
                        } else if (!isMinorAdultCountValid()) {
                          return 'There should be at least 1 adult or minor';
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText2,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _minorCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => node.unfocus(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field cannot be empty';
                        } else if (!isMinorAdultCountValid()) {
                          return 'There should be at least 1 adult or minor';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Square Code',
            style: Theme
                .of(context)
                .textTheme
                .bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _squareCodeController,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onEditingComplete: () => node.unfocus(),
            validator: (value) {
              if (value.isEmpty || value.length < 4) {
                return 'This field required minimum 4 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Square Code',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 20),
          Text(
            'Comment',
            style: Theme
                .of(context)
                .textTheme
                .bodyText2,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _commentController,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Comments',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
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

  bool isMinorAdultCountValid() {
    if (_adultCountController.text.isEmpty ||
        _minorCountController.text.isEmpty)
      return false;
    else if (int.parse(_adultCountController.text) +
        int.parse(_minorCountController.text) <=
        0) return false;

    return true;
  }

  bool isEmailPhoneValid() {
    return _emailController.text.isNotEmpty || _phoneController.text.isNotEmpty;
  }

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      logger.d('Invalid form submission');
      return;
    }

    DateTime bookingDateTime = context
        .read<TaxiProvider>()
        .date;
    String ticketId = _generateTicketId(_nameController.text);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Booking booking = Booking(
      ticketID: ticketId,
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      email: _emailController.text,
      tripReturnTime: _returnTimeController.text,
      tripStartTime: _dptTimeController.text,
      adult: _adultCountController.text,
      minor: _minorCountController.text,
      status: Booking.BOOKING_STATUS_PENDING,
      agentName: context
          .read<AppUserProvider>()
          .appUser
          ?.name,
      bookingAgentID: context
          .read<AppUserProvider>()
          .appUser
          ?.userID,
      bookingDate: DateFormat('ddMMMyyy').format(bookingDateTime),
      bookingDateTimeStamp: bookingDateTime,
      comment: _commentController.text,
      taxiID: widget.taxidetails.id,
      todayDateString: DateFormat('ddMMMyyy').format(bookingDateTime),
      device: Platform.isAndroid ? 'android' : 'ios',
      startDeparting: true,
      isAdminTicketBook: false,
      ticketDepartureSide: 'Bayside Beach',
      returnDepartureStatus: Booking.BOOKING_STATUS_PENDING,
      startDepartureStatus: Booking.BOOKING_STATUS_PENDING,
      buildVersion: packageInfo.version,
      isRoundTrip: widget.isRoundTrip,
      squareCode: _squareCodeController.text,
    );

/*
    // Create new bookings
    List<TaxiStats> taxiStats = context
        .read<TaxiProvider>()
        .taxiStats;
    TaxiStats taxiStat = taxiStats?.firstWhere(
          (e) => e.taxiID == widget.taxiId,
      orElse: () => null,
    );

    TimingStat startTimingStat = taxiStat.startTimingList
        .firstWhere((e) => e.time == booking.tripStartTime);
    TimingStat returnTimingStat;
    if (widget.isRoundTrip)
      returnTimingStat = taxiStat.returnTimingList
          .firstWhere((e) => e.time == booking.tripReturnTime);

    // int totalStartTimingTickets = startTimingStat.alreadyBooked +
    //     int.parse(booking.adult) +
    //     int.parse(booking.minor);
    // int totalReturnTimingTickets = returnTimingStat.alreadyBooked +
    //     int.parse(booking.adult) +
    //     int.parse(booking.minor);

    var startSeat = await FirestoreDBService.getAvailableSeatCount(
        bookingDateTime, _dptTimeController.text, "tripStartTime");

    var returnSeat = await FirestoreDBService.getAvailableSeatCount(
        bookingDateTime, _returnTimeController.text, "tripReturnTime");

    startSeat = taxiStat.totalSeats - startSeat;
    returnSeat = taxiStat.totalSeats - returnSeat;
    var bookedSeat = int.tryParse(_adultCountController.text) +
        int.tryParse(_minorCountController.text);

    if (startSeat < bookedSeat) {
      final snackBar = SnackBar(
        content: Text(
            'Available seats for ${_dptTimeController.text} is $startSeat.'),
        backgroundColor: Theme
            .of(context)
            .errorColor,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }
    if (returnSeat < bookedSeat) {
      final snackBar = SnackBar(
        content: Text(
            'Available seats for ${_returnTimeController
                .text} is $returnSeat.'),
        backgroundColor: Theme
            .of(context)
            .errorColor,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }

    startTimingStat.alreadyBooked +=
        int.parse(booking.adult) + int.parse(booking.minor);
    if (widget.isRoundTrip)
      returnTimingStat.alreadyBooked +=
          int.parse(booking.adult) + int.parse(booking.minor);
*/

    if (!_formKey.currentState.validate()) {
      logger.d('Invalid form submission');
      return;
    }

    String dptdocId ='${widget.taxidetails.id}${DateFormat('ddMMMyyyy').format(context.read<TaxiProvider>()
        .date)}BS${widget.selectedDepartTime}';
    print(dptdocId.replaceAll(new RegExp(r"\s+"), ""));


  String returndocId ='${widget.taxidetails.id}${DateFormat('ddMMMyyyy').format(context.read<TaxiProvider>()
        .date)}MB${widget.selectedReturnTime}';
    print(returndocId.replaceAll(new RegExp(r"\s+"), ""));

    setState(() => isBtnLoading = true);


    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference dptpostRef = FirebaseFirestore.instance.collection(
          "bookings").doc(dptdocId);

      DocumentReference returnpostRef = FirebaseFirestore.instance.collection(
          "bookings").doc(returndocId);


      var requiresNoOfSeat = int.parse(booking.adult) +
          int.parse(booking.minor);

      var dptreamainingSeats = 0;

      var returnreamainingSeats = 0;
      await transaction.get(dptpostRef).asStream().forEach((element) {
        element
            .data()
            ?.values
            ?.forEach((element) {
          if (element['status'] != "Cancelled") {
            dptreamainingSeats = dptreamainingSeats +
                int.parse(element["adult"]) +
                int.parse(element["minor"]);
          }
        });
      });
      await transaction.get(returnpostRef).asStream().forEach((element) {
        element
            .data()
            ?.values
            ?.forEach((element) {
          if (element['status'] != "Cancelled") {
            returnreamainingSeats = returnreamainingSeats +
                int.parse(element["adult"]) +
                int.parse(element["minor"]);
          }
        });
      });

      dptreamainingSeats = widget.taxidetails.totalSeats - dptreamainingSeats;
      returnreamainingSeats=widget.taxidetails.totalSeats - returnreamainingSeats;

      if (!(requiresNoOfSeat <= dptreamainingSeats)) {
        setState(() => isBtnLoading = false);
        singelTripAlert(dptreamainingSeats);
        return;
      }

      if (widget.isRoundTrip) {
        if(!(requiresNoOfSeat <=returnreamainingSeats)){
          setState(() => isBtnLoading = false);
          singelTripAlert(returnreamainingSeats);
          return;
        }
        booking.startDocumentPath=dptdocId;
        booking.returnDocumentPath=returndocId;
        if((dptreamainingSeats > 0 && dptreamainingSeats <  widget.taxidetails.totalSeats )) {
          transaction.update(dptpostRef, {ticketId: booking.toJson()});
        }else if (dptreamainingSeats ==  widget.taxidetails.totalSeats  ) {
          transaction.set(dptpostRef, {ticketId: booking.toJson()});
        }
        if ((returnreamainingSeats > 0 && returnreamainingSeats <  widget.taxidetails.totalSeats )) {

          transaction.update(returnpostRef, {ticketId: booking.toJson()});
        }else if(returnreamainingSeats== widget.taxidetails.totalSeats ){

          transaction.set(returnpostRef, {ticketId: booking.toJson()});
        }
      }else {
        booking.startDocumentPath=dptdocId;
        booking.returnDocumentPath="";
        if((dptreamainingSeats > 0 && dptreamainingSeats <  widget.taxidetails.totalSeats )) {
          transaction.update(dptpostRef, {ticketId: booking.toJson()});
        }else if (dptreamainingSeats ==  widget.taxidetails.totalSeats  ) {
          transaction.set(dptpostRef, {ticketId: booking.toJson()});
        }
      }


      _updateMyView(dptdocId,ticketId);


    }
  );

/* setState(() => isBtnLoading = true);
    ticketId = await FirestoreDBService.createBooking(
      booking,
      taxiStat,
      context.read<TaxiProvider>().date,
    );
    setState(() => isBtnLoading = false);

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketBookedScreen(ticketId: ticketId),
      ),
    );*/
}

String _generateTicketId(String username) {
  String randomNumber = '${1000 + Random().nextInt(9999 - 1000)}';
  if (username.isNotEmpty && username.length >= 4) {
    return '${username.substring(0, 4)}-$randomNumber';
  } else {
    return '${username.substring(0, username.length)}-$randomNumber';
  }
}

  void _updateMyView(String dptdocId, String ticketId) {
    setState(() => isBtnLoading = false);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketBookedScreen(dptdocId: dptdocId,
            ticketId: ticketId),
      ),
    );
  }

  /*void roundTripAlert(int dptseats, int returnSeats) {
    final snackBar = SnackBar(
      content: Text(
          'Available seats for'
              ' ${_dptTimeController.text} is $dptseats.'
              ' \n Available seats for ${_returnTimeController.text} is $returnSeats.' ),
      backgroundColor: Theme
          .of(context)
          .errorColor,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    return;
  }*/

  void singelTripAlert(int dptSeats) {
    final snackBar = SnackBar(
      content: Text(
          'Available seats for'
              ' ${_dptTimeController.text} is $dptSeats.'),
      backgroundColor: Theme
          .of(context)
          .errorColor,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    return;
  }






  }
