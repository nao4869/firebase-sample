import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/post_provider.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:firebase_sample/pages/home/home_screen_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';
import 'constants/colors.dart';
import 'models/switch_app_theme_provider.dart';
import 'models/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstTime = prefs.getBool('isInitial');

  if (firstTime == null || firstTime) {
    // 初回起動時のみ、groupを追加
    Firestore.instance.collection('groups').add({});
    prefs.setBool('isInitial', false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PostProvider(
            posts: [],
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeScreenNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            isLightTheme: true,
            darkMode: false,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SwitchAppThemeProvider(
            currentTheme: colorList[6],
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Returns a locale which will be used by the app
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      home: HomeScreen(),
    );
  }
}
