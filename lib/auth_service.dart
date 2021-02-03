import 'package:water_taxi_miami/global.dart';
import 'package:water_taxi_miami/models/app_user.dart';
import 'package:water_taxi_miami/services/database_service.dart';

class AuthService {
  static Future<AppUser> loginUser(String pinCode) {
    return FirestoreDBService.logInUser(pinCode).then((value) {
      if (value == null) {
        return Future.error('PIN Code did not match. Enter a valid code');
      }

      return value;
    });
  }

  static Future<AppUser> signUpUser(
      String name, String phoneNo, String emailAddress, String pinCode) async {
    if (!(await FirestoreDBService.isPinCodeUnique(pinCode))) {
      logger.d('Pin code is not unique. Could not sign up user.');
      return Future.error('Pin code is not unique. Could not register user.');
    }

    if (!(await FirestoreDBService.isPhoneUnique(phoneNo))) {
      logger.d('Phone is not unique. Could not sign up user.');
      return Future.error(
          'Phone number is not unique. Could not register user.');
    }

    return FirestoreDBService.signUpUser(name, phoneNo, emailAddress, pinCode);
  }
}
