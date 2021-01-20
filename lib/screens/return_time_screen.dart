import 'package:flutter/material.dart';
import 'package:water_taxi_miami/screens/booking_form_screen.dart';

class ReturnTimeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Select Return Time'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingFormScreen(
                                bookingType: BookingType.NEW_BOOKING,
                              )),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text('2:45 PM'),
                      subtitle: Text(
                        'Departure Time',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '34 left',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) {
                return SizedBox(height: 10);
              },
            ),
          ],
        ),
      ),
    );
  }
}
