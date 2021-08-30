import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/screens/log_in_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class TicketBookedScreen extends StatefulWidget {
  final String dptdocId;
  final String ticketId;
  TicketBookedScreen({
    Key key,
    @required this.dptdocId,
    @required this.ticketId,
  }) : super(key: key);

  @override
  _TicketBookedScreenState createState() => _TicketBookedScreenState();
}

class _TicketBookedScreenState extends State<TicketBookedScreen> {
  Booking booking;
  Future<Booking> f;
  Future<bool> isUserCrew;
  GlobalKey key;

  @override
  void initState() {
    super.initState();
    key = GlobalKey();
  //  f = FirestoreDBService.getBooking(widget.dptdocId,widget.ticketId);
   // print(f);


    isUserCrew = FirestoreDBService.isPinReservedForCrew(
        context.read<AppUserProvider>().appUser?.userPin);
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
      body: SingleChildScrollView(
        child: StreamBuilder<Booking>(
          stream: FirestoreDBService.streamBooking(widget.dptdocId,widget.ticketId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }else if(snapshot.hasError){
              return Center(
                child: Text(
                    'Something went wrong Please try again after some time'),
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
                        data: generateQRData(booking,widget.dptdocId,widget.ticketId),
                        version: QrVersions.auto,
                        size: 250.0,
                      ),
                    ],
                  ),
                ),
                //_approveButtons(booking),
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
                  child: RaisedButton(
                    child: Text('E-mail ticket to client'),
                    onPressed: () {
                      _onPressSendEmailBtn(context, booking);
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
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _approveButtons(Booking booking) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<bool>(
        future: isUserCrew,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError || !snapshot.data) {
            return Container();
          }

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
                                await FirestoreDBService.updateBookingStatus(
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
                                await FirestoreDBService.updateBookingStatus(
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
      ),
    );
  }

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    Navigator.of(context).popUntil((route) => false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LogInScreen()),
    );
  }

  Future<void> _onPressShareBtn(BuildContext context, Booking b) async {
    if (b == null) {
      logger.e('Booking is null');
      return simpleShare(b);
    }

    String path = await createQrPicture(generateQRData(b,widget.dptdocId,widget.ticketId));

    if (path == null) {
      return simpleShare(b);
    }

    return Share.shareFiles(
      [path],
      subject: 'Ticket Detail',
      text: generateGeneralShareText(b),
    );
  }

  Future<void> _onPressSendEmailBtn(BuildContext context, Booking b) async {
    if (b == null) {
      logger.e('Booking is null');
      return simpleShare(b);
    }

    String path = await createQrPicture(generateQRData(b,widget.dptdocId,widget.ticketId));

    if (path == null) {
      return simpleShare(b);
    }

    final Email email = Email(
      body: generateGeneralShareText(b),
      subject: 'Ticket Detail',
      recipients: b.email != null && b.email.isNotEmpty ? [b.email] : [],
      attachmentPaths: [path],
      isHTML: false,
    );

    return FlutterEmailSender.send(email);
  }

  Future<void> simpleShare(Booking booking) {
    return Share.share(
      generateGeneralShareText(booking),
      subject: 'Ticket Detail',
    );
  }

  String generateQRData(Booking b, String dptdocId, String ticketId) {
    return json.encode(b.toRealJson());
  }

  String generateGeneralShareText(Booking b) {
    return 'Ticket ID:${b.ticketID}\nCustomer Name: ${b.customerName}\nEmail: ${b.email}\nPhone: ${b.customerPhone}\nSales Agent Name: ${b.agentName}\nDeparting Time BS: ${b.tripStartTime}\nDeparting Time MB: ${b.tripReturnTime}\nComment: ${b.comment}';
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
