import 'package:flutter/cupertino.dart';
import 'package:water_taxi_miami/models/app_user.dart';

class AppUserProvider extends ChangeNotifier {
  AppUser _appUser;

  AppUser get appUser => _appUser;

  set appUser(AppUser value) {
    _appUser = value;
    notifyListeners();
  }
}
