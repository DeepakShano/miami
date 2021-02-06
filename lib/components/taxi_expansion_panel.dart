import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/return_time_screen.dart';

class TaxiExpansionPanelList extends StatefulWidget {
  final List<TaxiDetail> taxiDetails;

  const TaxiExpansionPanelList({
    Key key,
    @required this.taxiDetails,
  }) : super(key: key);

  @override
  _TaxiExpansionPanelListState createState() => _TaxiExpansionPanelListState();
}

class _TaxiExpansionPanelListState extends State<TaxiExpansionPanelList> {
  List<bool> isExpandedList;

  @override
  void initState() {
    isExpandedList = widget.taxiDetails.map((e) => false).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ExpansionPanel> expansionPanels = List();

    isExpandedList.clear();
    for (TaxiDetail t in widget.taxiDetails) {
      int index = widget.taxiDetails.indexOf(t);
      expansionPanels.add(buildExpansionPanel(t, true));
    }

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          isExpandedList[index] = isExpanded;
        });
      },
      children: [...expansionPanels],
    );
  }

  ExpansionPanel buildExpansionPanel(TaxiDetail taxiDetail, bool isExpanded) {
    bool isWeekend = [6, 7].contains(DateTime.now().weekday);

    List<String> departTimings = isWeekend
        ? taxiDetail.weekEndStartTiming
        : taxiDetail.weekDayStartTiming;

    List<TaxiStats> taxiStats = context.watch<TaxiProvider>().taxiStats;
    TaxiStats taxiStat = taxiStats?.firstWhere(
      (element) => element.taxiID == taxiDetail.id,
      orElse: () => null,
    );
    List<TimingStat> departTimingStats = taxiStat?.startTimingList;

    return ExpansionPanel(
      isExpanded: isExpanded,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(
            taxiDetail?.name ?? 'Untitled Taxi',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        );
      },
      body: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: departTimings.length,
        itemBuilder: (context, index) {
          String departTiming = departTimings.elementAt(index);

          int seatsBooked = departTimingStats
              ?.firstWhere((e) => e.time == departTiming, orElse: () => null)
              ?.alreadyBooked;
          int seatsLeft = taxiDetail.totalSeats - (seatsBooked ?? 0);

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReturnTimeScreen(
                    taxiId: taxiDetail.id,
                    selectedDepartTime: departTiming,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                departTiming ?? '-',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.black87),
              ),
              subtitle: Text(
                'Departure Time',
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
          );
        },
      ),
    );
  }
}
