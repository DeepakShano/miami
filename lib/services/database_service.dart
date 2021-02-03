import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';

class FirestoreDBService {
  static Stream<List<TaxiDetail>> streamTaxiDetails() {
    return FirebaseFirestore.instance
        .collection('TaxiDetail')
        .snapshots()
        .map((event) {
      return event.docs.map((e) => TaxiDetail.fromJson(e.data()))?.toList();
    });
  }

  /// Returns booking ID
  static Future<String> createBooking(Booking booking) {
    String bookingId = booking.ticketID ?? Uuid().v4();

    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(bookingId)
        .set(booking.toJson())
        .then((value) => bookingId);
  }

  static Future<Booking> getBooking(String id) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(id)
        .get()
        .then((value) {
      if (!value.exists) {
        logger.d('No booking found with ID $id');
        return null;
      }

      logger.d('Booking found with ID $id, ${value.data()}');

      return Booking.fromJson(value.data());
    });
  }
}
