import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:water_taxi_miami/models/booking.dart';

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
              'Problem finding Booking detail in QR code. Make sure QR code is valid.'),
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
      body: Column(
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
        ],
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
