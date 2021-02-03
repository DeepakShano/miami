import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
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
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();

  @override
  void initState() {
    if (widget.selectedDepartTime != null) {
      _departureTimeController.text = widget.selectedDepartTime;
    }

    if (widget.selectedReturnTime != null) {
      _returnTimeController.text = widget.selectedReturnTime;
    }

    if (DEBUG) {
      _nameController.text = 'Test';
      _phoneController.text = '9895952623';
      _emailController.text = 'a@a.a';
      _minorCountController.text = '5';
      _adultCountController.text = '5';
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
                  child: Text('Submit'),
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
              if (value.isEmpty) {
                return 'This field cannot be empty';
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
              if (value.isEmpty) {
                return 'This field cannot be empty';
              } else if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value)) {
                return 'Enter a valid email address';
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

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      logger.d('Invalid form submission');
      return;
    }

    Booking booking = Booking(
      ticketID: Uuid().v4(),
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      email: _emailController.text,
      tripReturnTime: _returnTimeController.text,
      tripStartTime: _departureTimeController.text,
      adult: _adultCountController.text,
      minor: _minorCountController.text,
      status: 'Pending',
      agentName: context.read<AppUserProvider>().appUser?.name,
      bookingAgentID: context.read<AppUserProvider>().appUser?.userID,
      bookingDate: DateFormat('dd/MM/yyy').format(DateTime.now()),
      bookingDateTimeStamp: DateTime.now(),
      comment: '',
      taxiID: widget.taxiId,
    );

    // Create new bookings
    String ticketId = await FirestoreDBService.createBooking(booking);

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
