import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_taxi_miami/components/app_drawer.dart';
import 'package:water_taxi_miami/models/admin_message.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class MessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Message of the Day'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<AdminMessage>(
          future: FirestoreDBService.getAdminMessage(DateTime.now()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('There was some issue..'),
              );
            }

            AdminMessage message = snapshot.data;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message?.messageDate ??
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 20),
                  Text(
                    message?.message ?? 'No message today',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontStyle: message == null
                            ? FontStyle.italic
                            : FontStyle.normal),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
