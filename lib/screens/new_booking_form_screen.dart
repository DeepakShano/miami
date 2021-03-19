import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/ticket_booked_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

import '../global.dart';

class NewBookingFormScreen extends StatefulWidget {
  final String taxiId;
  final String selectedDepartTime;
  final String selectedReturnTime;

  NewBookingFormScreen({
    Key key,
    @required this.selectedDepartTime,
    @required this.selectedReturnTime,
    @required this.taxiId,
  }) : super(key: key);

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
      _emailController.text = 'a@a.a';
      _minorCountController.text = '1';
      _adultCountController.text = '1';
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
                width: MediaQuery.of(context).size.width,
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
            enabled: false,
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
            enabled: false,
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
                        } else if (!isMinorAdultCountValid()) {
                          return 'There should be at least 1 adult or minor';
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

    DateTime bookingDateTime = context.read<TaxiProvider>().date;

    Booking booking = Booking(
      ticketID: Uuid().v4(),
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      email: _emailController.text,
      tripReturnTime: _returnTimeController.text,
      tripStartTime: _dptTimeController.text,
      adult: _adultCountController.text,
      minor: _minorCountController.text,
      status: 'Pending',
      agentName: context.read<AppUserProvider>().appUser?.name,
      bookingAgentID: context.read<AppUserProvider>().appUser?.userID,
      bookingDate: DateFormat('dd/MM/yyy').format(bookingDateTime),
      bookingDateTimeStamp: bookingDateTime,
      comment: '',
      taxiID: widget.taxiId,
      todayDateString: DateFormat('ddMMMyyy').format(bookingDateTime),
    );

    // Create new bookings
    List<TaxiStats> taxiStats = context.read<TaxiProvider>().taxiStats;
    TaxiStats taxiStat = taxiStats?.firstWhere(
      (e) => e.taxiID == widget.taxiId,
      orElse: () => null,
    );

    TimingStat startTimingStat = taxiStat.startTimingList
        .firstWhere((e) => e.time == booking.tripStartTime);
    TimingStat returnTimingStat = taxiStat.returnTimingList
        .firstWhere((e) => e.time == booking.tripReturnTime);
    startTimingStat.alreadyBooked +=
        int.parse(booking.adult) + int.parse(booking.minor);
    returnTimingStat.alreadyBooked +=
        int.parse(booking.adult) + int.parse(booking.minor);

    setState(() => isBtnLoading = true);
    String ticketId = await FirestoreDBService.createBooking(
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
    );
  }
}
