import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeUtils {
  static final ThemeData defaultAppThemeData = appTheme();

  static ThemeData appTheme() {
    return ThemeData(
      primaryColor: Color(0xFFF88546),
      accentColor: Color(0xFF234958),
      hintColor: Color(0xFF999999),
      // dividerColor: Color(0xFFE5E3DC),
      // highlightColor: Color(0xFFE28777),
      // disabledColor: Color(0xFFE5E3DC),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xFFF88546),
        textTheme: ButtonTextTheme.primary,
        shape: StadiumBorder(),
        disabledColor: Color(0xFFE5E3DC),
        height: 50,
      ),
      scaffoldBackgroundColor: Color(0xFFFDFBEF),
      cardColor: Color(0xFFFDFBEF),
      cardTheme: CardTheme(elevation: 5),
      // canvasColor: Colors.black,
      appBarTheme: AppBarTheme(
        color: Color(0xFFFDFBEF).withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Color(0xFFF88546),
        ),
      ),
      // pageTransitionsTheme: PageTransitionsTheme(builders: {
      //   TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      //   TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      // }),
      textTheme: TextTheme(
          headline4: TextStyle(fontWeight: FontWeight.w900),
          headline5: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
          headline6:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF88546)),
          subtitle1: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF88546)),
          subtitle2: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF88546)),
          bodyText2: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          caption: TextStyle(fontSize: 13, color: Color(0xFFF88546)),
          button: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

TextStyle appBarTitleStyle(BuildContext context) =>
    Theme.of(context).textTheme.subtitle2.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        );

TextStyle textFieldLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.caption.copyWith(
          color: Theme.of(context).accentColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

TextStyle textFieldHintStyle(BuildContext context) =>
    Theme.of(context).textTheme.caption.copyWith(
          color: Theme.of(context).hintColor,
          fontWeight: FontWeight.normal,
          height: 3,
        );

TextStyle textFieldInputStyle(BuildContext context) =>
    Theme.of(context).textTheme.caption.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.normal,
        );
