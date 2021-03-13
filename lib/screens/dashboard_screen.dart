import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/components/app_drawer.dart';
import 'package:water_taxi_miami/components/taxi_expansion_panel.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/message_screen.dart';

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
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            _datePicker(context),
            SizedBox(height: 20),
            Consumer<TaxiProvider>(
              builder: (context, value, child) {
                List<TaxiDetail> taxiDetails = value.taxis;

                if (taxiDetails == null || taxiDetails.isEmpty) {
                  return Center(
                    child: Text('No taxis available'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TaxiExpansionPanelList(taxiDetails: taxiDetails),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    DateTime date = context.watch<TaxiProvider>().date;
    String dateStr = DateFormat('dd-MMM-yyyy (EEEE)').format(date);

    DateTime startOfToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () async {
          DateTime selectedDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365 * 100)),
          );

          if (selectedDate == null) return;

          context.read<TaxiProvider>().date = selectedDate;
        },
        child: Card(
          child: Container(
            child: Row(
              children: [
                Expanded(child: Text(dateStr)),
                Icon(Icons.arrow_drop_down),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
      ),
    );
  }
}
