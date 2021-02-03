import 'package:flutter/cupertino.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class TaxiProvider extends ChangeNotifier {
  List<TaxiDetail> taxis = List();

  TaxiProvider() {
    streamTaxiDetails();
  }

  streamTaxiDetails() {
    FirestoreDBService.streamTaxiDetails().listen((event) {
      taxis = event;
      notifyListeners();
    });
  }
}
