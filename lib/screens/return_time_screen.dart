import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
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

    bool isWeekend =
        [6, 7].contains(context.watch<TaxiProvider>().date.weekday);

    List<String> returnTimings = isWeekend
        ? taxiDetail.weekEndReturnTiming
        : taxiDetail.weekDayReturnTiming;

    List<TaxiStats> taxiStats = context.watch<TaxiProvider>().taxiStats;
    TaxiStats taxiStat = taxiStats?.firstWhere(
      (element) => element.taxiID == taxiDetail.id,
      orElse: () => null,
    );
    List<TimingStat> returnTimingStats = taxiStat?.returnTimingList;

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
                  String returnTiming = returnTimings.elementAt(index);

                  int seatsBooked = returnTimingStats
                      ?.firstWhere((e) => e.time == returnTiming,
                          orElse: () => null)
                      ?.alreadyBooked;
                  int seatsLeft = taxiDetail.totalSeats - (seatsBooked ?? 0);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewBookingFormScreen(
                            selectedDepartTime: selectedDepartTime,
                            selectedReturnTime: returnTimings.elementAt(index),
                            taxidetails: taxiDetail,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          returnTiming ?? '-',
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
                              '${seatsLeft ?? 0}',
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
