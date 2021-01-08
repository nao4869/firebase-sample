import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreenNotifier extends ChangeNotifier {
  SettingsScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
  }) {
    //
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  // ダークモード切り替え関数
  void updateDarkMode(bool val) {
    themeNotifier.setThemeData = !val;
  }
}