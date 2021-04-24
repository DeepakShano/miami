import 'package:flutter/material.dart';
import 'package:share/share.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Text('${widget.barcodeResult}'),
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
