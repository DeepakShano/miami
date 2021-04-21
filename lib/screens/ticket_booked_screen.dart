import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/screens/log_in_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class TicketBookedScreen extends StatefulWidget {
  final String ticketId;

  TicketBookedScreen({
    Key key,
    @required this.ticketId,
  }) : super(key: key);

  @override
  _TicketBookedScreenState createState() => _TicketBookedScreenState();
}

class _TicketBookedScreenState extends State<TicketBookedScreen> {
  Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined),
            onPressed: () {
              _onPressShareBtn(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<Booking>(
        future: FirestoreDBService.getBooking(widget.ticketId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('There was some issue..'),
            );
          }

          Booking booking = snapshot.data;

          return Column(
            children: [
              SizedBox(height: 40),
              Text(
                'Ticket Booked',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 40),
              QrImage(
                data: generateQRData(booking),
                version: QrVersions.auto,
                size: 250.0,
              ),
              SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: RaisedButton(
                  child: Text('Message ticket to client'),
                  onPressed: () {
                    _onPressSecondaryBtn(context, booking);
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
          );
        },
      ),
    );
  }

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    Navigator.of(context).popUntil((route) => false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LogInScreen()),
    );
  }

  Future<void> _onPressSecondaryBtn(BuildContext context, Booking b) async {
    String uri =
        Uri.encodeFull('sms:${b?.customerPhone}?body=${generateShareText(b)}');
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      logger.e('Could not launch $uri');
    }
  }

  Future<void> _onPressShareBtn(BuildContext context) async {
    Share.share(generateShareText(booking), subject: 'Ticket Detail');
  }

  String generateQRData(Booking b) {
    return 'Ticket ID:${b.ticketID}\nCustomer Name: ${b.customerName}\nSales Agent Name: ${b.agentName}\nDeparting Time BS: ${b.tripStartTime}\nDeparting Time MB: ${b.tripReturnTime}\nComment: ${b.comment}';
  }

  String generateShareText(Booking booking) {
    return 'Water Taxi Miami\n305-600-2511\nwww.watertaximiami.com\nFor Boarding make sure to be at least 5 minutes before boarding time at Water Taxi station\n305-600-2511\nDisclaimer...................\nWe are NOT responsible for any weather conditions, Personal belongings, Captain hold the right to change route and cancel trips, This is NOT a Sightseeing tour.';
  }
}
