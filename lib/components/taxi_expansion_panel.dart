import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';

class TaxiExpansionPanelList extends StatefulWidget {
  final List<TaxiDetail> taxiDetails;
  final bool showDepartureTime;
  final Function(TaxiDetail, String,int) onTap;

  const TaxiExpansionPanelList({
    Key key,
    @required this.taxiDetails,
    this.showDepartureTime = true,
    this.onTap,
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
    bool isWeekend =
        [6, 7].contains(context.watch<TaxiProvider>().date.weekday);

    List<String> timings;
    if (widget.showDepartureTime) {
      timings = isWeekend
          ? taxiDetail.weekEndStartTiming
          : taxiDetail.weekDayStartTiming;
    } else {
      timings = isWeekend
          ? taxiDetail.weekEndReturnTiming
          : taxiDetail.weekDayReturnTiming;
    }

    List<TaxiStats> taxiStats = context.watch<TaxiProvider>().taxiStats;
    TaxiStats taxiStat = taxiStats?.firstWhere(
      (element) => element.taxiID == taxiDetail.id,
      orElse: () => null,
    );
    List<TimingStat> timingStats;
    if (widget.showDepartureTime) {
      timingStats = taxiStat?.startTimingList;
    } else {
      timingStats = taxiStat?.returnTimingList;
    }

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
        itemCount: timings.length,
        itemBuilder: (context, index) {
          String timeStr = timings.elementAt(index);



          return new FutureBuilder (
              future:  _getRemaingseat(taxiDetail,timings.elementAt(index)),
              builder: (context, snapshot) {
                int seatsLeft = taxiDetail.totalSeats -(snapshot.data ?? 0) ;
                return InkWell(
                  onTap: () =>
                  widget.onTap != null ? widget.onTap(taxiDetail, timeStr,index) : null,
                  child: ListTile(
                    title: Text(
                      timeStr ?? '-',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.black87),
                    ),
                    subtitle: Text(
                      widget.showDepartureTime ? 'Departure Time' : 'Return Time',
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
                        ),
                      ],
                    ),
                  ),
                );
              });




        },
      ),
    );
  }

Future<int> _getRemaingseat(TaxiDetail taxiDetail, String elementAt) async {
    String dptdocId ='${taxiDetail.id}${DateFormat('ddMMMyyyy').format(context.read<TaxiProvider>()
        .date)}${elementAt}';
    int count=0;
   // print(dptdocId.replaceAll(new RegExp(r"\s+"), ""));
    await FirebaseFirestore.instance.collection(
        "bookings").doc(dptdocId).get().asStream().forEach((element) {
         // print(element.id);
      element
          .data()
          ?.values
          ?.forEach((element) {
        if (element['status'] != "Cancelled") {
          count = count +
              int.parse(element["adult"]) +
              int.parse(element["minor"]);
        }
      });
    });
  return count;
  }
}
