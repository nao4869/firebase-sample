import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool isLightTheme;
  bool darkMode;

  ThemeProvider({
    this.isLightTheme,
    this.darkMode,
  });

  ThemeData get getThemeData => isLightTheme ? lightTheme : darkTheme;

  set setThemeData(bool val) {
    if (val) {
      isLightTheme = true;
      darkMode = false;
    } else {
      isLightTheme = false;
      darkMode = true;
    }
    notifyListeners();
  }
}

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  fontFamily: 'Raleway',
  backgroundColor: Color(0xFF000000),
  accentColor: Colors.blue,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: Colors.black54,
  textTheme: ThemeData.light().textTheme.copyWith(
        bodyText1: TextStyle(
          color: Color.fromRGBO(20, 51, 51, 1),
        ),
        bodyText2: TextStyle(
          color: Color.fromRGBO(20, 51, 51, 1),
        ),
        headline6: TextStyle(
          fontSize: 20,
          fontFamily: 'RobotoCondensed',
          fontWeight: FontWeight.bold,
        ),
      ),
);

final lightTheme = ThemeData(
  highlightColor: Colors.grey[200],
  splashColor: Colors.grey[200],
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  accentColor: Colors.blue,
  brightness: Brightness.light,
  backgroundColor: Color(0xFFE5E5E5),
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.white54,
  fontFamily: 'Raleway',
  textTheme: ThemeData.light().textTheme.copyWith(
        bodyText1: TextStyle(
          color: Color.fromRGBO(20, 51, 51, 1),
        ),
        bodyText2: TextStyle(
          color: Color.fromRGBO(20, 51, 51, 1),
        ),
        headline6: TextStyle(
          fontSize: 20,
          fontFamily: 'RobotoCondensed',
          fontWeight: FontWeight.bold,
        ),
      ),
);
