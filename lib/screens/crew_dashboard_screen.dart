import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/components/app_drawer.dart';
import 'package:water_taxi_miami/components/taxi_expansion_panel.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/crew_booking_list_screen.dart';
import 'package:water_taxi_miami/screens/message_screen.dart';
import 'package:water_taxi_miami/screens/scanner_booking_detail_screen.dart';

class CrewDashboardScreen extends StatefulWidget {
  @override
  _CrewDashboardScreenState createState() => _CrewDashboardScreenState();
}

class _CrewDashboardScreenState extends State<CrewDashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int radioGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Crew Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              String scannerResult = await FlutterBarcodeScanner.scanBarcode(
                '#F88546',
                'Cancel',
                true,
                ScanMode.QR,
              );

              if (scannerResult == null || scannerResult == '-1') {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Invalid QR code. Please try again.'),
                    backgroundColor: Theme
                        .of(context)
                        .errorColor,
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ScannerBookingDetailScreen(
                        barcodeResult: scannerResult,
                      ),
                ),
              );
            },
          ),
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
            SizedBox(height: 40),
            _datePicker(context),
            SizedBox(height: 20),
            _radioSelector(context),
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
                    showDepartureTime: radioGroupValue == 0,
                    onTap: (TaxiDetail taxi, String time) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CrewBookingListScreen(
                            taxiId: taxi.id,
                            time: time,
                          ),
                        ),
                      );
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

  Widget _datePicker(BuildContext context) {
    DateTime date = context.watch<TaxiProvider>().date;
    String dateStr = DateFormat('MMM dd, yyyy (EEEE)').format(date);

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

  Widget _radioSelector(BuildContext context) {
    List<String> labels = ['Bayside Departure', 'Miami Beach'];

    return Wrap(
      spacing: 10,
      children: List<Widget>.generate(
        labels.length,
            (int index) {
          bool isSelected = radioGroupValue == index;

          return ChoiceChip(
            label: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                isSelected
                    ? Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.done,
                    color: Theme.of(context).primaryColor,
                  ),
                )
                    : Container(height: 24),
                Text(
                  '${labels.elementAt(index)}',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color:
                    isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.all(10),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected && !isSelected) {
                setState(() {
                  radioGroupValue = index;
                });
              }
            },
          );
        },
      ).toList(),
    );
  }
}
