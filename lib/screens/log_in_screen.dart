import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/app_user.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/screens/dashboard_screen.dart';
import 'package:water_taxi_miami/screens/sign_up_screen.dart';
import 'package:water_taxi_miami/services/database_service.dart';

import '../global.dart';
import '../services/auth_service.dart';
import 'crew_dashboard_screen.dart';

class LogInScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              'Water Taxi Miami',
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 40),
            Text(
              'LOG IN',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 40),
            Text(
              'Enter your PIN',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: PinInputTextField(
                controller: _pinController,
                pinLength: 4,
                decoration: BoxLooseDecoration(
                  bgColorBuilder: PinListenColorBuilder(
                    Theme.of(context).primaryColor.withOpacity(0.9),
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ),
                  strokeColorBuilder: PinListenColorBuilder(
                    Theme.of(context).dividerColor,
                    Colors.transparent,
                  ),
                ),
                textInputAction: TextInputAction.go,
                enabled: true,
                keyboardType: TextInputType.number,
                onChanged: (pin) {
                  // _otp = pin;
                },
                enableInteractiveSelection: true,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  child: Text('Sign In'),
                  onPressed: () {
                    _onPressPrimaryBtn(context);
                  },
                  textColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  child: Text('Request for sign as Agent?'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  textColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressPrimaryBtn(BuildContext context) async {
    if (_pinController.text == null || _pinController.text.length != 4) {
      logger.d('Invalid form submission');
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Enter your 4 digit pin code'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    // Check if pin belongs to crew
    bool isPinForCrew =
        await FirestoreDBService.isPinReservedForCrew(_pinController.text);

    // Sign in user
    AppUser user =
        await AuthService.loginUser(_pinController.text).catchError((error) {
      if (error.runtimeType == String) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    });

    if (user != null) {
      context.read<AppUserProvider>().appUser = user;

      if (isPinForCrew) {
        // Go to crew's dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CrewDashboardScreen()),
        );
      } else {
        // Go to normal dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    }
  }
}
