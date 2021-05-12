import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/services/database_service.dart';

import '../global.dart';

class ScannerBookingDetailScreen extends StatefulWidget {
  final String barcodeResult;

  ScannerBookingDetailScreen({
    Key key,
    @required this.barcodeResult,
  }) : super(key: key);

  @override
  _ScannerBookingDetailScreenState createState() =>
      _ScannerBookingDetailScreenState();
}

class _ScannerBookingDetailScreenState
    extends State<ScannerBookingDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> isUserCrew;

  @override
  void initState() {
    super.initState();
    isUserCrew = FirestoreDBService.isPinReservedForCrew(
        context.read<AppUserProvider>().appUser?.userPin);
  }

  @override
  Widget build(BuildContext context) {
    Booking booking;
    try {
      Map<String, dynamic> map = json.decode(widget.barcodeResult);
      logger.d(map);

      booking = Booking.fromRealJson(map);
    } catch (e) {
      logger.e('Exception converting QR code to Booking model.');
      logger.e(e);

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            'Problem finding Booking detail in QR code. Make sure QR code is valid.',
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Scan'),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined),
            onPressed: () {
              _onPressShareBtn(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Booking Detail',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 40),
            Text('Agent Name: ${booking?.agentName ?? '-'}'),
            SizedBox(height: 16),
            Text(
              'Customer Name: ${booking?.customerName ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Customer Email: ${booking?.email ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Customer Phone: ${booking?.customerPhone ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Booking Date: ${booking?.bookingDate ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Start Time: ${booking?.tripStartTime ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Return Time: ${booking?.tripReturnTime ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Adults: ${booking?.adult ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Minors: ${booking?.minor ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Comments: ${booking?.comment ?? '-'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 40),
            _approveButtons(booking?.ticketID),
            SizedBox(height: 40),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: RaisedButton(
                child: Text('Share Ticket Detail'),
                onPressed: () {
                  _onPressSecondaryBtn(context);
                },
                textColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: OutlineButton(
                child: Text('Done'),
                onPressed: () {
                  _onPressPrimaryBtn(context);
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _approveButtons(String bookingId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<bool>(
        future: isUserCrew,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError || !snapshot.data) {
            return Container();
          }

          return StreamBuilder<Booking>(
            stream: FirestoreDBService.streamBooking(bookingId),
            builder: (context, bookingSnapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text('There was some issue..'),
                );
              }

              Booking booking = bookingSnapshot.data;

              return Column(
                children: [
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: Text(booking.startDeparting
                            ? 'BS Departure'
                            : 'MB Departure'),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: RaisedButton(
                          child: Text(booking.startDepartureStatus ==
                                  Booking.BOOKING_STATUS_APPROVED
                              ? 'Approved'
                              : 'Approve'),
                          onPressed: booking.startDepartureStatus ==
                                  Booking.BOOKING_STATUS_APPROVED
                              ? null
                              : () async {
                                  await FirestoreDBService
                                      .updateStartDptBookingStatus(
                                    booking.ticketID,
                                    Booking.BOOKING_STATUS_APPROVED,
                                  );

                                  // If other status is also approved then set overall status to APPROVED
                                  if (booking.returnDepartureStatus ==
                                      Booking.BOOKING_STATUS_APPROVED) {
                                    await FirestoreDBService
                                        .updateBookingStatus(
                                      booking.ticketID,
                                      Booking.BOOKING_STATUS_APPROVED,
                                    );
                                  }
                                },
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(booking.startDeparting
                            ? 'MB Departure'
                            : 'BS Departure'),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: RaisedButton(
                          child: Text(booking.returnDepartureStatus ==
                                  Booking.BOOKING_STATUS_APPROVED
                              ? 'Approved'
                              : 'Approve'),
                          onPressed: booking.returnDepartureStatus ==
                                  Booking.BOOKING_STATUS_APPROVED
                              ? null
                              : () async {
                                  await FirestoreDBService
                                      .updateReturnDptBookingStatus(
                                    booking.ticketID,
                                    Booking.BOOKING_STATUS_APPROVED,
                                  );

                                  // If other status is also approved then set overall status to APPROVED
                                  if (booking.startDepartureStatus ==
                                      Booking.BOOKING_STATUS_APPROVED) {
                                    await FirestoreDBService
                                        .updateBookingStatus(
                                      booking.ticketID,
                                      Booking.BOOKING_STATUS_APPROVED,
                                    );
                                  }
                                },
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    Navigator.of(context).pop();
  }

  Future<void> _onPressSecondaryBtn(BuildContext context) async {
    Share.share(widget.barcodeResult, subject: 'Ticket Detail');
  }

  Future<void> _onPressShareBtn(BuildContext context) async {
    Share.share(generateShareText(), subject: 'Ticket Detail');
  }

  String generateShareText() {
    return 'Water Taxi Miami\n305-600-2511\nwww.watertaximiami.com\nFor Boarding make sure to be at least 5 minutes before boarding time at Water Taxi station\n305-600-2511\nDisclaimer...................\nWe are NOT responsible for any weather conditions, Personal belongings, Captain hold the right to change route and cancel trips, This is NOT a Sightseeing tour.';
  }
}
