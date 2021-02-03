import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/providers/taxi_provider.dart';
import 'package:water_taxi_miami/screens/log_in_screen.dart';
import 'package:water_taxi_miami/theme/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<TaxiProvider>(
            builder: (context, child) => child,
            create: (_) => TaxiProvider(),
          ),
        ],
        builder: (context, _) {
          return MaterialApp(
            title: 'Water Taxi Miami',
            debugShowCheckedModeBanner: false,
            theme: ThemeUtils.defaultAppThemeData,
            home: LogInScreen(),
          );
        },
      ),
    );
  }
}
