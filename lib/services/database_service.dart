import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  /// Returns true if [pinCode] matches crew's pin code. Otherwise returns false.
  static Future<bool> isPinReservedForCrew(String pinCode) {
    return FirebaseFirestore.instance
        .collection('metadata')
        .doc('login')
        .get()
        .then((docSnapshot) {
      if (!docSnapshot.exists || !docSnapshot.data().containsKey('crewPin')) {
        logger.d('No reserved pin found for crew.');
        return false;
      }

      return docSnapshot.data()['crewPin'] == pinCode;
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
    String docId = '${booking.taxiID}${booking.bookingDate}';
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

  static Future<Booking> getBooking(String dptdocId, String ticketId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .doc(dptdocId)
        .get()
        .asStream()
        .forEach((element) {
      if (element.id == ticketId) {
        print(element.id);
        print(ticketId);
        return Booking.fromJson(element.data());
      }
    });
  }

  static Stream<Booking> streamBooking(String docid, String ticketId)  {
    return FirebaseFirestore.instance
        .collection('bookings')
        .doc(docid)
        .snapshots()
        .map((event) {
      if (!event.exists) return null;

      return Booking.fromJson(event.data()[ticketId]);
    });
  }

  static Future<List<Booking>> getBookingForCrew(
    String taxiId,
    DateTime bookingDate,
    String startTime,
    String endTime,
  ) async {
    final String dateStr = DateFormat('ddMMMyyy').format(bookingDate);
    final Query commonQuery = FirebaseFirestore.instance
        .collection('manageBooking')
        .where('taxiID', isEqualTo: taxiId)
        .where('bookingDate', isEqualTo: dateStr);

    List<Booking> startTimeBookings = await commonQuery
        .where('tripStartTime', isEqualTo: startTime)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size == 0) {
        logger.d('No bookings matching $dateStr, $startTime');
        return [];
      }

      return querySnapshot.docs
          .map<Booking>((e) => Booking.fromJson(e.data()))
          .toList();
    });

    List<Booking> returnTimeBookings = await commonQuery
        .where('tripReturnTime', isEqualTo: startTime)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size == 0) {
        logger.d('No bookings matching $dateStr, $startTime');
        return [];
      }

      return querySnapshot.docs
          .map<Booking>((e) => Booking.fromJson(e.data()))
          .toList();
    });

    return <Booking>[...startTimeBookings, ...returnTimeBookings];
  }

  static Future<int> getAvailableSeatCount(
      DateTime selectedDate, String ticketTime, String timeType) {
    String dateStr = DateFormat('ddMMMyyyy').format(selectedDate);
    var count = 0;
    print("$ticketTime");
    print("$timeType");
    return FirebaseFirestore.instance
        .collection("manageBooking")
        .where('bookingDate', isEqualTo: dateStr)
        .where(timeType, isEqualTo: ticketTime)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size == 0) {
        logger.d('No seat available $dateStr');
        return count;
      }
      querySnapshot.docs.forEach((element) {
        var data = element.data();

        if (data['status'].toString() == "Cancelled") {
          logger.d('Cancelled $dateStr');
          return count;
        } else {
          count = count +
              int.parse(data["adult"].toString()) +
              int.parse(data["minor"].toString());
          print("$count");
          return count;
        }
      });
      return count;
    });
  }

  static Future<int> reamingSeatCount(DocumentReference postRef,
      Transaction transaction, DateTime selectedDate) async {
    var count = 0;
    return transaction.get(postRef).asStream().forEach((element) {
      element.data()?.values?.forEach((element) {
        if (element['status'] != "Cancelled") {
          count =
              count + int.parse(element["adult"]) + int.parse(element["minor"]);
        }
      });
      return (34 - count);
    });
  }

  static Future<List<Booking>> streamTickets(String agentId) async {
    List<Booking> bookings = new List<Booking>();
    List<String> bookingid=new List<String>();

    await FirebaseFirestore.instance
        .collection("bookings")
        .get()
        .asStream()
        .forEach((element) {
      for (var i = 0; i < element.size; i++) {
        element.docs[i].data().forEach((key, value) {

          if(!(bookingid.contains(key))){
            bookingid.add(key);
            bookings.add(Booking.fromJson(value));
          }
        });
      }

      bookings
          .where((element) =>
              element.bookingAgentID == agentId &&
              element.status != Booking.BOOKING_STATUS_CANCELLED)
          .toSet().toList();
      return bookings;
    });
    return bookings;
  }

  static Future<void> updateBookingStatus(String bookingId, String status) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(bookingId)
        .update({'status': status});
  }

  static Future<void> updateStartDptBookingStatus(
      String bookingId, String status) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(bookingId)
        .update({'startDepartureStatus': status});
  }

  static Future<void> updateReturnDptBookingStatus(
      String bookingId, String status) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(bookingId)
        .update({'returnDepartureStatus': status});
  }

  static Future<void> deleteBooking(Booking booking, String condition) {

    String statsDocId;
    if(condition=='both'){

      _deleteFunction('${booking.taxiID}${booking.bookingDate}${booking.tripStartTime}',booking);
      _deleteFunction('${booking.taxiID}${booking.bookingDate}${booking.tripReturnTime}',booking);


    }else if(condition=='departure'){
       statsDocId =
          '${booking.taxiID}${booking.bookingDate}${booking.tripStartTime}';
    }else if(condition=='return'){
       statsDocId =
          '${booking.taxiID}${booking.bookingDate}${booking.tripReturnTime}';
    }
    _deleteFunction(statsDocId,booking);

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

  static Future<TaxiDetail> getTaxidetails(String taxiId) {
    return FirebaseFirestore.instance
        .collection('TaxiDetail')
        .doc(taxiId)
        .get()
        .then((docSnapshot) {
      if (!docSnapshot.exists) {
        logger.d('No stats found for taxi ID $taxiId');
        return null;
      }

      return TaxiDetail.fromJson(docSnapshot.data());
    });
  }

  static Future<TaxiStats> getTaxiStats(String taxiId, DateTime date) {
    String dateStr = DateFormat('ddMMMyyyy').format(date);
    String docId = '$taxiId$dateStr';
    logger.d('Document ID: $docId');

    return FirebaseFirestore.instance
        .collection('todayStat')
        .doc(docId)
        .get()
        .then((docSnapshot) {
      if (!docSnapshot.exists) {
        logger.d('No stats found for taxi ID $taxiId and date $dateStr');
        return null;
      }

      return TaxiStats.fromJson(docSnapshot.data());
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

  static _deleteFunction(String statsDocId, Booking booking) {

    return FirebaseFirestore.instance
        .collection('bookings')
        .doc(statsDocId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        logger.w('Today Stat document does not exist');
        return Future.error('Today stat document does not exist');
      }

      print(booking.status);
      print(booking.ticketID);
      booking.status = Booking.BOOKING_STATUS_CANCELLED;
      print(booking.status);
      return FirebaseFirestore.instance
          .collection("bookings")
          .doc(statsDocId)
          .update({booking.ticketID: booking.toJson()});
    });
  }


}
