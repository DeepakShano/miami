import 'package:flutter/cupertino.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class TaxiProvider extends ChangeNotifier {
  List<TaxiDetail> taxis = List();
  List<TaxiStats> taxiStats = List();

  TaxiProvider() {
    streamTaxiDetails();
  }

  streamTaxiDetails() {
    FirestoreDBService.streamTaxiDetails().listen((event) {
      taxis = event;
      notifyListeners();

      // TODO: This will create duplicate streams when event is called again
      streamTaxiStats();
    });
  }

  void streamTaxiStats() {
    for (TaxiDetail taxi in taxis) {
      FirestoreDBService.streamTaxiStats(taxi.id, DateTime.now())
          .listen((taxiStat) {
        logger.d('streamTaxiStats event triggered');

        if (taxiStat == null) {
          logger.d('No taxi stat found. Generating new');
          FirestoreDBService.generateNewTaxiStat(taxi, DateTime.now());
          return;
        }

        int oldElementIdx = taxiStats.indexWhere((e) => e.taxiID == taxi.id);

        if (oldElementIdx == -1) {
          taxiStats.add(taxiStat);
        } else {
          taxiStats[oldElementIdx] = taxiStat;
        }

        notifyListeners();
      });
    }
  }
}
