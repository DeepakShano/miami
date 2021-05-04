import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
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
  Future<Booking> f;
  GlobalKey key;

  @override
  void initState() {
    super.initState();
    key = GlobalKey();
    f = FirestoreDBService.getBooking(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined),
            onPressed: () {
              _onPressShareBtn(context, booking);
            },
          ),
        ],
      ),
      body: StreamBuilder<Booking>(
        stream: FirestoreDBService.streamBooking(widget.ticketId),
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

          booking = snapshot.data;

          return Column(
            children: [
              SizedBox(height: 40),
              Text(
                'Ticket Booked',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 40),
              RepaintBoundary(
                key: key,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    QrImage(
                      data: generateQRData(booking),
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    color: Colors.green,
                    child: Text(
                        booking.status == Booking.BOOKING_STATUS_APPROVED
                            ? 'Approved'
                            : 'Approve'),
                    onPressed: booking.status == Booking.BOOKING_STATUS_APPROVED
                        ? null
                        : () async {
                            await FirestoreDBService.updateBookingStatus(
                              booking.ticketID,
                              Booking.BOOKING_STATUS_APPROVED,
                            );
                          },
                    textColor: Colors.white,
                  ),
                  SizedBox(width: 20),
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                        booking.status == Booking.BOOKING_STATUS_REJECTED
                            ? 'Rejected'
                            : 'Reject'),
                    onPressed: booking.status == Booking.BOOKING_STATUS_REJECTED
                        ? null
                        : () async {
                            await FirestoreDBService.updateBookingStatus(
                              booking.ticketID,
                              Booking.BOOKING_STATUS_REJECTED,
                            );
                          },
                    textColor: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: RaisedButton(
                  child: Text('Message ticket to client'),
                  onPressed: () {
                    _onPressShareBtn(context, booking);
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
    String uri = Uri.encodeFull(
        'sms:${b?.customerPhone}?body=${generateSMSShareText(b)}');
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      logger.e('Could not launch $uri');
    }
  }

  Future<void> _onPressShareBtn(BuildContext context, Booking b) async {
    if (b == null) {
      logger.e('Booking is null');
      return simpleShare(b);
    }

    String path = await createQrPicture(generateQRData(b));

    if (path == null) {
      return simpleShare(b);
    }

    return Share.shareFiles(
      [path],
      subject: 'Ticket Detail',
      text: generateGeneralShareText(b),
    );
  }

  Future<void> simpleShare(Booking booking) {
    return Share.share(
      generateGeneralShareText(booking),
      subject: 'Ticket Detail',
    );
  }

  String generateQRData(Booking b) {
    return json.encode(b.toRealJson());
  }

  String generateGeneralShareText(Booking b) {
    return 'Ticket ID:${b.ticketID}\nCustomer Name: ${b.customerName}\nSales Agent Name: ${b.agentName}\nDeparting Time BS: ${b.tripStartTime}\nDeparting Time MB: ${b.tripReturnTime}\nComment: ${b.comment}';
  }

  String generateSMSShareText(Booking b) {
    return 'Water Taxi Miami\n305-600-2511\nwww.watertaximiami.com\nFor Boarding make sure to be at least 5 minutes before boarding time at Water Taxi station\n305-600-2511\nDisclaimer...................\nWe are NOT responsible for any weather conditions, Personal belongings, Captain hold the right to change route and cancel trips, This is NOT a Sightseeing tour.';
  }

  Future<String> createQrPicture(String qr) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '$tempPath/$ts.png';

    try {
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      ByteData pngBytes = byteData.buffer.asByteData();

      await writeToFile(pngBytes, path);

      return path;
    } catch (exception) {
      logger.e(exception);
      return null;
    }
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
