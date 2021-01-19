import 'package:firebase_sample/constants/colors.dart';
import 'package:flutter/material.dart';

class SwitchAppThemeProvider with ChangeNotifier {
  SwitchAppThemeProvider({
    this.currentTheme,
    this.selectedImagePath,
  });

  Color currentTheme;
  String selectedImagePath;

  void switchTheme(Color color) {
    currentTheme = color;
    notifyListeners();
  }

  void switchThemeById(int id) {
    currentTheme = colorList[id];
    notifyListeners();
  }

  void updateSelectedImagePath(String imagePath) {
    selectedImagePath = imagePath;
    notifyListeners();
  }

  int getCurrentThemeNumber() {
    if (currentTheme == lightGreen && selectedImagePath.isEmpty) {
      return 0;
    } else if (currentTheme == lightRed && selectedImagePath.isEmpty) {
      return 1;
    } else if (currentTheme == red && selectedImagePath.isEmpty) {
      return 2;
    } else if (currentTheme == green && selectedImagePath.isEmpty) {
      return 3;
    } else if (currentTheme == pinky && selectedImagePath.isEmpty) {
      return 4;
    } else if (currentTheme == lightPurple && selectedImagePath.isEmpty) {
      return 5;
    } else if (currentTheme == lightOrange && selectedImagePath.isEmpty) {
      return 6;
    } else if (currentTheme == blue && selectedImagePath.isEmpty) {
      return 7;
    } else if (selectedImagePath == imageList[0]) {
      return 0;
    } else if (selectedImagePath == imageList[1]) {
      return 1;
    } else if (selectedImagePath == imageList[2]) {
      return 2;
    } else if (selectedImagePath == imageList[3]) {
      return 3;
    } else if (selectedImagePath == imageList[4]) {
      return 4;
    } else {
      return 0;
    }
  }
}
