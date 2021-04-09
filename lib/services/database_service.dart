import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/admin_message.dart';
import 'package:water_taxi_miami/models/app_user.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';
import 'package:water_taxi_miami/models/taxi_stats.dart';

class FirestoreDBService {
  /// Returns true if no other user has matching [phone]
  static Future<bool> isPhoneUnique(String phone) {
    return FirebaseFirestore.instance
        .collection('UserInfo')
        .where('phone', isEqualTo: phone)
        .get()
        .then((querySnapshot) {
      return querySnapshot.size == 0;
    });
  }

  /// Returns true if no other user has matching [pinCode]
  static Future<bool> isPinCodeUnique(String pinCode) {
    return FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userPin', isEqualTo: pinCode)
        .get()
        .then((querySnapshot) {
      return querySnapshot.size == 0;
    });
  }

  static Future<AppUser> signUpUser(
    String name,
    String phoneNo,
    String emailAddress,
    String pinCode,
  ) {
    String uid = Uuid().v4();

    AppUser appUser = AppUser(
      phone: phoneNo,
      name: name,
      status: 'Pending',
      email: emailAddress,
      enrollDate: DateFormat('dd MMM, yyyy').format(DateTime.now()),
      userID: uid,
      userPin: pinCode,
      userType: 'Agent',
      fcmToken: '', // TODO: Missing default value
    );

    return FirebaseFirestore.instance
        .collection('UserInfo')
        .doc(uid)
        .set(appUser.toJson())
        .then((value) => appUser);
  }

  static Future<AppUser> logInUser(String pinCode) {
    return FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userPin', isEqualTo: pinCode)
        // .where('status', isEqualTo: 'Approved')
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size == 0) {
        return null;
      }

      return AppUser.fromJson(querySnapshot.docs.first.data());
    });
  }

  static Stream<List<TaxiDetail>> streamTaxiDetails() {
    return FirebaseFirestore.instance
        .collection('TaxiDetail')
        .snapshots()
        .map((event) {
      return event.docs.map((e) => TaxiDetail.fromJson(e.data()))?.toList();
    });
  }

  /// Returns booking ID
  static Future<String> createBooking(
    Booking booking,
    TaxiStats updatedTaxiStats,
    DateTime date,
  ) {
    String bookingId = booking.ticketID ?? Uuid().v4();

    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(bookingId)
        .set(booking.toJson())
        .then((_) {
      String docId = '${booking.taxiID}${DateFormat('ddMMMyyy').format(date)}';

      return FirebaseFirestore.instance
          .collection('todayStat')
          .doc(docId)
          .set(updatedTaxiStats.toJson());
    }).then((value) => bookingId);
  }

  /// Returns booking ID
  static Future<String> updateBooking(
    String id,
    Booking booking,
    TaxiStats updatedTimeStats,
  ) async {
    String docId =
        '${booking.taxiID}${DateFormat('ddMMMyyy').format(booking.bookingDateTimeStamp)}';
    return FirebaseFirestore.instance
        .collection('todayStat')
        .doc(docId)
        .update(updatedTimeStats.toJson())
        .then((_) {
      return FirebaseFirestore.instance
          .collection('manageBooking')
          .doc(id)
          .update(booking.toJson())
          .then((value) => id);
    });
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

      return Booking.fromJson(value.data());
    });
  }

  static Future<AdminMessage> getAdminMessage(DateTime date) {
    String dateStr = DateFormat('dd/MM/yyyy').format(date);

    return FirebaseFirestore.instance
        .collection('adminMessage')
        .where('messageDate', isEqualTo: dateStr)
        .limit(1)
        .get()
        .then((value) {
      if (value.size == 0) {
        logger.d('No message of day found for date $dateStr');
        return null;
      }

      return AdminMessage.fromJson(value.docs.first.data());
    });
  }

  static Stream<List<Booking>> streamTickets(String agentId) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        // .where('bookingDateTimeStamp', isGreaterThanOrEqualTo: DateTime.now())
        .where('bookingAgentID', isEqualTo: agentId)
        .orderBy('bookingDateTimeStamp', descending: true)
        .snapshots()
        .map((event) {
      return event.docs.map((e) => Booking.fromJson(e.data()))?.toList();
    });
  }

  static Future<void> deleteBooking(Booking booking) {
    String statsDocId =
        '${booking.taxiID}${DateFormat('ddMMMyyy').format(booking.bookingDateTimeStamp)}';

    return FirebaseFirestore.instance
        .collection('todayStat')
        .doc(statsDocId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        logger.w('Today Stat document does not exist');
        return Future.error('Today stat document does not exist');
      }

      TaxiStats taxiStat = TaxiStats.fromJson(snapshot.data());

      TimingStat startTimingStat = taxiStat.startTimingList
          .firstWhere((e) => e.time == booking.tripStartTime);
      TimingStat returnTimingStat = taxiStat.returnTimingList
          .firstWhere((e) => e.time == booking.tripReturnTime);

      int adultMinorCount = int.parse(booking.adult) + int.parse(booking.minor);
      startTimingStat.alreadyBooked -= adultMinorCount;
      returnTimingStat.alreadyBooked -= adultMinorCount;

      return FirebaseFirestore.instance
          .collection('todayStat')
          .doc(statsDocId)
          .update(taxiStat.toJson());
    }).then((value) {
      return FirebaseFirestore.instance
          .collection('manageBooking')
          .doc(booking.ticketID)
          .delete();
    });
  }

  static Stream<TaxiStats> streamTaxiStats(String taxiId, DateTime date) {
    String dateStr = DateFormat('dd-MMM-yyyy').format(date);
    logger.d('dateStr: $dateStr');

    return FirebaseFirestore.instance
        .collection('todayStat')
        .where('taxiID', isEqualTo: taxiId)
        .where('todayDate', isEqualTo: dateStr)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.size == 0) {
        logger.d('No stats found for taxi ID $taxiId and date $dateStr');
        return null;
      }

      return TaxiStats.fromJson(querySnapshot.docs.first.data());
    });
  }

  static Future<TaxiStats> getTaxiStats(String taxiId, DateTime date) {
    String dateStr = DateFormat('dd-MMM-yyyy').format(date);
    logger.d('dateStr: $dateStr');

    return FirebaseFirestore.instance
        .collection('todayStat')
        .where('taxiID', isEqualTo: taxiId)
        .where('todayDate', isEqualTo: dateStr)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size == 0) {
        logger.d('No stats found for taxi ID $taxiId and date $dateStr');
        return null;
      }

      return TaxiStats.fromJson(querySnapshot.docs.first.data());
    });
  }

  static Future<TaxiStats> generateNewTaxiStat(
    TaxiDetail taxiDetail,
    DateTime date,
  ) {
    TaxiStats taxiStats = TaxiStats(
      taxiID: taxiDetail.id,
      name: taxiDetail.name,
      totalSeats: taxiDetail.totalSeats,
      todayDate: DateFormat('dd-MMM-yyyy').format(date),
      startTimingList: List(),
      returnTimingList: List(),
    );

    bool isWeekend = [6, 7].contains(date.weekday);

    List<String> startTimings = isWeekend
        ? taxiDetail.weekEndStartTiming
        : taxiDetail.weekDayStartTiming;
    List<String> returnTimings = isWeekend
        ? taxiDetail.weekEndReturnTiming
        : taxiDetail.weekDayReturnTiming;

    startTimings.forEach((e) =>
        taxiStats.startTimingList.add(TimingStat(alreadyBooked: 0, time: e)));
    returnTimings.forEach((e) =>
        taxiStats.returnTimingList.add(TimingStat(alreadyBooked: 0, time: e)));

    String docId = '${taxiDetail.id}${DateFormat('ddMMMyyyy').format(date)}';
    return FirebaseFirestore.instance
        .collection('todayStat')
        .doc(docId)
        .set(taxiStats.toJson())
        .then((value) => taxiStats);
  }
}
