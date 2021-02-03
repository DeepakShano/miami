import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/admin_message.dart';
import 'package:water_taxi_miami/models/app_user.dart';
import 'package:water_taxi_miami/models/booking.dart';
import 'package:water_taxi_miami/models/taxi_detail.dart';

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
  static Future<String> createBooking(Booking booking) {
    String bookingId = booking.ticketID ?? Uuid().v4();

    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(bookingId)
        .set(booking.toJson())
        .then((value) {
      int totalSeatsBooked =
          int.parse(booking.adult) + int.parse(booking.minor);

      return FirebaseFirestore.instance
          .collection('TaxiDetail')
          .doc(booking.taxiID)
          .update({'TotalSeats': FieldValue.increment(-totalSeatsBooked)});
    }).then((value) => bookingId);
  }

  /// Returns booking ID
  static Future<String> updateBooking(String id, Booking booking) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(id)
        .update(booking.toJson())
        .then((value) => id);
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

  static Future<void> deleteBooking(String id) {
    return FirebaseFirestore.instance
        .collection('manageBooking')
        .doc(id)
        .delete();
  }
}
