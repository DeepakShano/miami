import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/components/booking_list_item.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/ticket_booked_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

import '../global.dart';

class CrewBookingListScreen extends StatelessWidget {
  final String taxiId;
  final String time;

  const CrewBookingListScreen({
    Key key,
    @required this.taxiId,
    @required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = context.watch<TaxiProvider>().date;
    String dateStr = DateFormat('MMM dd, yyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket List'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _datePicker(context),
              SizedBox(height: 20),
              FutureBuilder<List<Booking>>(
                future: FirestoreDBService.getBookingForCrew(
                  taxiId,
                  date,
                  time,
                  time,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    logger.e(snapshot.error);
                    return Center(
                      child: Text('There was some issue..'),
                    );
                  }

                  List<Booking> bookings = snapshot.data;

                  if (bookings == null || bookings.isEmpty) {
                    return Center(
                      child: Text('There no tickets available'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      Booking booking = bookings.elementAt(index);
                      String dptdocId ='${booking.taxiID}${
                          booking.tripStartTime}${booking.tripStartTime}';
                      return BookingListItem(
                        booking: bookings.elementAt(index),
                        onEditTap: null,
                        onDeleteTap: null,
                        onQrTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketBookedScreen(dptdocId: dptdocId,
                                  ticketId: booking.ticketID),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) {
                      return SizedBox(height: 8);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    DateTime date = context.watch<TaxiProvider>().date;
    String dateStr = DateFormat('MMM dd, yyyy (EEEE)').format(date);

    return GestureDetector(
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
    );
  }
}
