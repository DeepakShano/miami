import 'package:flutter/material.dart';
import 'package:water_taxi_miami/components/app_drawer.dart';
import 'package:water_taxi_miami/screens/message_screen.dart';
import 'package:water_taxi_miami/screens/return_time_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app_outlined),
            onPressed: () {},
          )
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {},
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(
                        'DAILY DEPARTURES Mon, Tue, Wed, Thu, Fri',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    );
                  },
                  body: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReturnTimeScreen()),
                          );
                        },
                        child: ListTile(
                          title: Text('1:30 PM'),
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
                      );
                    },
                  ),
                  isExpanded: true,
                ),
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text('WEEKEND SCHEDULE Sat, Sun'),
                    );
                  },
                  body: ListTile(
                    title: Text('Item 2 child'),
                    subtitle: Text('Details goes here'),
                  ),
                  isExpanded: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
