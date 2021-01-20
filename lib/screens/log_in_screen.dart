import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:water_taxi_miami/screens/dashboard_screen.dart';
import 'package:water_taxi_miami/screens/sign_up_screen.dart';

class LogInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                    );
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
}
