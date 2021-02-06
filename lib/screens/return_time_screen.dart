import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/new_booking_form_screen.dart';

class ReturnTimeScreen extends StatelessWidget {
  final String taxiId;
  final String selectedDepartTime;

  const ReturnTimeScreen({
    Key key,
    @required this.taxiId,
    @required this.selectedDepartTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TaxiDetail> taxiDetails = context.watch<TaxiProvider>().taxis;

    TaxiDetail taxiDetail = taxiDetails.firstWhere(
      (e) => e.id == taxiId,
      orElse: () => null,
    );

    if (taxiDetail == null) {
      return Center(
        child: Text('Some issue'),
      );
    }

    bool isWeekend = [6, 7].contains(DateTime.now().weekday);

    List<String> returnTimings = isWeekend
        ? taxiDetail.weekEndReturnTiming
        : taxiDetail.weekDayReturnTiming;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Select Return Time'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Departure Time: $selectedDepartTime'),
              SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: returnTimings.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewBookingFormScreen(
                            selectedDepartTime: selectedDepartTime,
                            selectedReturnTime: returnTimings.elementAt(index),
                            taxiId: taxiId,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          returnTimings.elementAt(index) ?? '-',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.black87),
                        ),
                        subtitle: Text(
                          'Return Time',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${taxiDetail.totalSeats ?? 0}',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(color: Colors.black54),
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
      ),
    );
  }
}
