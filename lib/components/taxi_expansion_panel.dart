import 'package:flutter/material.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
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
          );
        },
      ),
    );
  }
}
