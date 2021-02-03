import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:water_taxi_miami/models/app_user.dart';

class AuthService {
  static Future<bool> loginUser(String pinCode) {
    return Future.delayed(Duration(seconds: 2), () => true);
  }

  static Future<void> signUpUser(String name, String phoneNo, String emailAddress) {
    String uid = Uuid().v4();

    AppUser appUser = AppUser(
      phone: phoneNo,
      name: name,
      status: '',
      // TODO: Missing default value
      email: emailAddress,
      enrollDate: DateFormat('dd MMM, yyyy').format(DateTime.now()),
      isPinON: true,
      // TODO: Missing default value
      userID: uid,
      userPin: '',
      // TODO: Missing default value
      userType: '',
      // TODO: Missing default value
      fcmToken: '', // TODO: Missing default value
    );

    return FirebaseFirestore.instance
        .collection('UserInfo')
        .doc(uid)
        .set(appUser.toJson());
  }
}
