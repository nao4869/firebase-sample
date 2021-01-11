import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/device_id_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:firebase_sample/pages/home/home_screen_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utility/device_data.dart';
import 'app_localizations.dart';
import 'constants/colors.dart';
import 'models/provider/switch_app_theme_provider.dart';
import 'models/provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstTime = prefs.getBool('isInitial');
  DocumentSnapshot referenceToUser;
  String groupId = '';

  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData;
  try {
    if (Platform.isAndroid) {
      deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }

  if (firstTime == null || firstTime) {
    // 初回起動時のみ、groupを追加
    final documentReference =
        await Firestore.instance.collection('groups').add({
      'deviceId': deviceData['androidId'],
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

    // groupIdを参照するuserを作成
    Firestore.instance.collection('users').add({
      'name': 'Not Settings',
      'imagePath': null,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'deviceId': deviceData['androidId'],
      'groupId': documentReference.documentID,
    });

    // groupIdを参照するcategoryを作成
    Firestore.instance.collection('category').add({
      'name': 'Tutorial',
      'groupId': documentReference.documentID,
    });
    groupId = documentReference.documentID;
    prefs.setBool('isInitial', false);
  } else {
    // 初回起動時以外に、deviceIdから該当するgroupIdを取得する
    Firestore.instance
        .collection('groups')
        .where('deviceId', isEqualTo: deviceData['androidId'])
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        groupId = ds.reference.documentID;
      }
    });
  }

  // ログイン中ユーザーへのReferenceを取得
  Firestore.instance
      .collection('users')
      .where('deviceId', isEqualTo: deviceData['androidId'])
      .getDocuments()
      .then((snapshot) {
    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
      referenceToUser = documentSnapshot;
      print(referenceToUser.reference.documentID);
    }
  });

  runApp(
    MultiProvider(
      providers: [
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
        ChangeNotifierProvider(
          create: (_) => CurrentGroupProvider(
            groupId: groupId,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserReferenceProvider(
            referenceToUser: referenceToUser,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceIdProvider(
            androidUid: deviceData['androidId'],
            iosUid: deviceData['identifierForVendor'],
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
