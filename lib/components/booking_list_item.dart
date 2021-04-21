import 'package:flutter/material.dart';
import 'package:water_taxi_miami/models/booking.dart';

class BookingListItem extends StatelessWidget {
  final Booking booking;
  final VoidCallback onQrTap;
  final VoidCallback onEditTap;
  final Function(Booking booking) onDeleteTap;

  const BookingListItem({
    Key key,
    this.booking,
    this.onQrTap,
    this.onEditTap,
    this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agent Name: ${booking.agentName}'),
            SizedBox(height: 16),
            Text(
              'Booking Name: ${booking.customerName}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Booking Date: ${booking.bookingDate}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Start Time: ${booking.tripStartTime}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Return Time: ${booking.tripReturnTime}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Total Passenger: ${int.parse(booking.adult) + int.parse(booking.minor)}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Adults: ${booking.adult}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 8),
            Text(
              'Minors: ${booking.minor}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FlatButton.icon(
                    onPressed: onQrTap,
                    label: Text('QR'),
                    icon: Icon(Icons.qr_code),
                  ),
                ),
                Expanded(
                  child: FlatButton.icon(
                    onPressed: onEditTap,
                    label: Text('Edit'),
                    icon: Icon(Icons.edit_outlined),
                    textColor: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  child: FlatButton.icon(
                    onPressed: onDeleteTap != null
                        ? () {
                            onDeleteTap(booking);
                          }
                        : null,
                    label: Text('Delete'),
                    icon: Icon(Icons.delete_outline),
                    textColor: Theme.of(context).errorColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
