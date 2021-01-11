import 'package:firebase_sample/constants/colors.dart';
import 'package:flutter/material.dart';

class SwitchAppThemeProvider with ChangeNotifier {
  SwitchAppThemeProvider({
    this.currentTheme,
  });

  Color currentTheme;

  void switchTheme(Color color) {
    currentTheme = color;
    notifyListeners();
  }

  void switchThemeById(int id) {
    currentTheme = colorList[id];
    notifyListeners();
  }

  int getCurrentThemeNumber() {
    if (currentTheme == lightGreen) {
      return 0;
    } else if (currentTheme == lightRed) {
      return 1;
    } else if (currentTheme == red) {
      return 2;
    } else if (currentTheme == green) {
      return 3;
    } else if (currentTheme == pinky) {
      return 4;
    } else if (currentTheme == lightPurple) {
      return 5;
    } else if (currentTheme == lightOrange) {
      return 6;
    } else if (currentTheme == yellow) {
      return 7;
    } else if (currentTheme == blue) {
      return 8;
    } else if (currentTheme == lightBlue) {
      return 9;
    } else {
      return 0;
    }
  }
}
