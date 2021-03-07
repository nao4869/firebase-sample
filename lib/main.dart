import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/provider/device_id_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/provider/withdrawal_status_provider.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:firebase_sample/pages/home/home_screen_notifier.dart';
import 'package:firebase_sample/pages/splash/splash_screen.dart';
import 'package:firebase_sample/pages/splash/user_registration_screen.dart';
import 'package:firebase_sample/tabs/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'utility/device_data.dart';
import 'app_localizations.dart';
import 'constants/colors.dart';
import 'models/provider/switch_app_theme_provider.dart';
import 'models/provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

  if (Platform.isAndroid) {
    _deviceId = deviceData['androidId'];
  } else {
    _deviceId = deviceData['identifierForVendor'];
  }

  await initUserReference();

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
            selectedImagePath: '',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrentGroupProvider(
            groupId: '',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrentParentCategoryIdProvider(
            currentParentCategoryId: '',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserReferenceProvider(
            referenceToUser: '',
            userSettingsReference: '',
            isDisplayCompletedTodo: true,
            isSortByCreatedAt: true,
            isSortCategoryByCreatedAt: true,
            isDisplayCheckBox: true,
            isDisplayCreatedAt: false,
            isDisplayOnlyCompletedTodo: false,
            currentParentCategoryIdReference: '',
            todoFontSize: 13.0,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceIdProvider(
            androidUid: deviceData['androidId'],
            iosUid: deviceData['identifierForVendor'],
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WithdrawalStatusProvider(
            isWithdrawn: false,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

String _deviceId = '';
QuerySnapshot _isUserExist;

class MyApp extends StatelessWidget {
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
      home: _isUserExist != null
          ? _isUserExist.size != 0
              ? SplashScreen()
              : UserRegistrationScreen()
          : SplashScreen(),
      routes: <String, WidgetBuilder>{
        'home-screen': (_) => HomeScreen(),
        'user-registration-screen': (_) => UserRegistrationScreen(),
        'tabs-screen': (_) => TabScreen(),
      },
    );
  }
}

// 初回ログイン判定
Future<void> initUserReference() async {
  try {
    _isUserExist = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .where('deviceIds', arrayContains: _deviceId)
        .get();
  } catch (error) {
    debugPrint('Group id does not exist');
  }
}
