import 'package:flutter/material.dart';
import 'package:water_taxi_miami/components/app_drawer.dart';

class MessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Message of the Day'),
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '12/01/2021',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 20),
            Text(
              'Gm TEAM;	•	FIRST DEPARTURE 12pm	•	LAST DEP. 8:30pm	•	ROUND TRIPS ONLY if not busy 	•	NO FREE BEER today 	•	MARK All BABIES ON YOUR RECEIPT, Every body counts! Let’s have a good day day thanks for  your support ! ',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
