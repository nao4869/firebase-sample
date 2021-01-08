import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:firebase_sample/pages/setting_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';

class SwitchApplicationTheme extends StatefulWidget {
  SwitchApplicationTheme();

  @override
  _SwitchApplicationThemeState createState() => _SwitchApplicationThemeState();
}

class _SwitchApplicationThemeState extends State<SwitchApplicationTheme> {
  int selectedThemeNumber;

  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    // final dbInstance = db.getDatabaseInfo();
    selectedThemeNumber = themeProvider.getCurrentThemeNumber();
    return Scaffold(
      backgroundColor: theme.isLightTheme ? white : darkBlack,
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme,
        title: Text(
          AppLocalizations.of(context).translate('editDesignTheme'),
          style: TextStyle(
            color: white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: SizedBox(
          width: 40,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: white,
            ),
            onPressed: () {
              // ポップ時にDBのアプリテーマを更新
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ColoredBox(
          color: theme.isLightTheme ? white : darkBlack,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              SettingTitle(
                title:
                    AppLocalizations.of(context).translate('editDesignTheme'),
              ),
              SettingRow(
                title: AppLocalizations.of(context).translate('lightGreen'),
                isEnable: themeProvider.currentTheme == lightGreen,
                onChange: (val) {
                  themeProvider.switchTheme(lightGreen);
                  selectedThemeNumber = 0;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('lightRed'),
                isEnable: themeProvider.currentTheme == lightRed,
                onChange: (val) {
                  themeProvider.switchTheme(lightRed);
                  selectedThemeNumber = 1;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('red'),
                isEnable: themeProvider.currentTheme == red,
                onChange: (val) {
                  themeProvider.switchTheme(red);
                  selectedThemeNumber = 2;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('blue'),
                isEnable: themeProvider.currentTheme == blue,
                onChange: (val) {
                  themeProvider.switchTheme(blue);
                  selectedThemeNumber = 3;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('lightBlue'),
                isEnable: themeProvider.currentTheme == lightBlue,
                onChange: (val) {
                  themeProvider.switchTheme(lightBlue);
                  selectedThemeNumber = 9;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('green'),
                isEnable: themeProvider.currentTheme == green,
                onChange: (val) {
                  themeProvider.switchTheme(green);
                  selectedThemeNumber = 4;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('pinky'),
                isEnable: themeProvider.currentTheme == pinky,
                onChange: (val) {
                  themeProvider.switchTheme(pinky);
                  selectedThemeNumber = 5;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('lightPurple'),
                isEnable: themeProvider.currentTheme == lightPurple,
                onChange: (val) {
                  themeProvider.switchTheme(lightPurple);
                  selectedThemeNumber = 6;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('lightOrange'),
                isEnable: themeProvider.currentTheme == lightOrange,
                onChange: (val) {
                  themeProvider.switchTheme(lightOrange);
                  selectedThemeNumber = 7;
                },
              ),
              const SizedBox(height: 5),
              SettingRow(
                title: AppLocalizations.of(context).translate('yellow'),
                isEnable: themeProvider.currentTheme == yellow,
                onChange: (val) {
                  themeProvider.switchTheme(yellow);
                  selectedThemeNumber = 8;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
