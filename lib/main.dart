import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:water_taxi_miami/screens/log_in_screen.dart';
import 'package:water_taxi_miami/theme/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Water Taxi Miami',
        debugShowCheckedModeBanner: false,
        theme: ThemeUtils.defaultAppThemeData,
        home: LogInScreen(),
      ),
    );
  }
}
