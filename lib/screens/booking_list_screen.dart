import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/components/booking_list_item.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/screens/edit_booking_screen.dart';
import 'package:water_taxi_miami/screens/ticket_booked_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class BookingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket List'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              StreamBuilder<List<Booking>>(
                  stream: FirestoreDBService.streamTickets(
                      context.watch<AppUserProvider>().appUser.userID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
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

                        return BookingListItem(
                          booking: bookings.elementAt(index),
                          onEditTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditBookingFormScreen(booking: booking),
                              ),
                            );
                          },
                          onQrTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketBookedScreen(
                                    ticketId: booking.ticketID),
                              ),
                            );
                          },
                          onDeleteTap: (String id) {
                            Widget okButton = FlatButton(
                              child: Text("Delete"),
                              onPressed: () {
                                FirestoreDBService.deleteBooking(id);
                                Navigator.pop(context);
                              },
                            );

                            Widget cancelButton = FlatButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            );

                            AlertDialog alert = AlertDialog(
                              title: Text("WTM"),
                              content: Text(
                                  "Do you really want to delete this booking?"),
                              actions: [
                                cancelButton,
                                okButton,
                              ],
                            );

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) {
                        return SizedBox(height: 8);
                      },
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
