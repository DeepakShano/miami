import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/components/app_drawer.dart';
import 'package:water_taxi_miami/components/taxi_expansion_panel.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/message_screen.dart';
import 'package:water_taxi_miami/screens/return_time_screen.dart';

import 'new_booking_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    bool isWeekend =
        [6, 7].contains(context.watch<TaxiProvider>().date.weekday);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                addRadioButton(0, 'One way', context),
                addRadioButton(1, 'Round trip', context),
              ],
            ),
            SizedBox(height: 20),
            _datePicker(context),
            SizedBox(height: 20),
            Consumer<TaxiProvider>(
              builder: (context, value, child) {
                List<TaxiDetail> taxiDetails = value.taxis;

                if (taxiDetails == null || taxiDetails.isEmpty) {
                  return Center(
                    child: Text('No taxis available'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TaxiExpansionPanelList(
                    taxiDetails: taxiDetails,
                    showDepartureTime: true,
                    onTap: (TaxiDetail taxiDetail, String time, index) {
                      List<String> returnTimings = isWeekend
                          ? taxiDetail.weekEndReturnTiming
                          : taxiDetail.weekDayReturnTiming;

                      if (returnTimings.length - 1 > index) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewBookingFormScreen(
                                      isRoundTrip:
                                          select == "One way" ? false : true,
                                      selectedDepartTime: time,
                                      selectedReturnTime: select == "One way"
                                          ? ""
                                          : returnTimings[index + 1],
                                      taxidetails: taxiDetail,
                                    )));
                      } else {
                        final snackBar = SnackBar(
                          content: Text(
                              'No return time available,you can choose one way trip to continue'),
                          backgroundColor: Theme.of(context).errorColor,
                        );
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ReturnTimeScreen(
                      //       taxiId: taxiDetail.id,
                      //       selectedDepartTime: time,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List gender = ["One way", "Round trip"];

  String select = "Round trip";

  Row addRadioButton(int btnValue, String title, context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Radio(
          activeColor: Theme.of(context).primaryColor,
          value: gender[btnValue],
          groupValue: select,
          onChanged: (value) {
            setState(() {
              print(value);
              select = value;
            });
          },
        ),
        Text(title)
      ],
    );
  }

  Widget _datePicker(BuildContext context) {
    DateTime date = context.watch<TaxiProvider>().date;
    String dateStr = DateFormat('dd-MMM-yyyy (EEEE)').format(date);

    DateTime startOfToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () async {
          DateTime selectedDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365 * 100)),
          );

          if (selectedDate == null) return;
          print("selected $selectedDate");
          context.read<TaxiProvider>().date = selectedDate;
        },
        child: Card(
          child: Container(
            child: Row(
              children: [
                Expanded(child: Text(dateStr)),
                Icon(Icons.arrow_drop_down),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
      ),
    );
  }
}
