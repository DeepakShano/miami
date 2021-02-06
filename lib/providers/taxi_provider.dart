import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class TaxiProvider extends ChangeNotifier {
  DateTime _date = DateTime.now();
  List<TaxiDetail> taxis = List();
  List<TaxiStats> taxiStats = List();

  List<StreamSubscription> _taxiStatsStreams = List();

  TaxiProvider() {
    streamTaxiDetails();
  }

  streamTaxiDetails() {
    FirestoreDBService.streamTaxiDetails().listen((event) {
      taxis = event;
      notifyListeners();

      _resetStatsListeners().then((_) => streamTaxiStats());
    });
  }

  void streamTaxiStats() {
    for (TaxiDetail taxi in taxis) {
      StreamSubscription streamSub =
          FirestoreDBService.streamTaxiStats(taxi.id, date)
              .listen((v) => taxiStatsListener(v, taxi));
      _taxiStatsStreams.add(streamSub);
    }
  }

  void taxiStatsListener(TaxiStats taxiStat, TaxiDetail taxi) {
    logger.d('streamTaxiStats event triggered');

    if (taxiStat == null) {
      logger.d('No taxi stat found. Generating new');
      FirestoreDBService.generateNewTaxiStat(taxi, date);
      return;
    }

    int oldElementIdx = taxiStats.indexWhere((e) => e.taxiID == taxi.id);

    if (oldElementIdx == -1) {
      taxiStats.add(taxiStat);
    } else {
      taxiStats[oldElementIdx] = taxiStat;
    }

    notifyListeners();
  }

  Future<void> _resetStatsListeners() {
    return Future.wait(_taxiStatsStreams.map((e) => e.cancel()));
  }

  DateTime get date => _date;

  set date(DateTime value) {
    logger.d('Updating date');

    if (_date != value) {
      // Date changed, remove old stats listeners, attached new listeners
      _resetStatsListeners().then((_) => streamTaxiStats());
    }

    _date = value;
    notifyListeners();
  }
}
