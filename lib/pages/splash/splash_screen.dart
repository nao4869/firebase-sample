import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/splash/splash_screen_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = 'splash-screen';

  const SplashScreen({
    this.userName,
    this.invitationCode,
  });

  final String userName;
  final String invitationCode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashScreenNotifier(
        context: context,
        switchAppThemeProvider: Provider.of(context),
        groupNotifier: Provider.of(context),
        parentCategoryIdNotifier: Provider.of(context),
        userNotifier: Provider.of(context, listen: false),
        userName: userName,
        invitationCode: invitationCode,
      ),
      child: _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final notifier = Provider.of<SplashScreenNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    notifier.initialize();
    return Scaffold(
      backgroundColor: theme.isLightTheme ? themeColor : darkBlack,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ColoredBox(
              color: Colors.transparent,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  switchAppThemeNotifier.currentTheme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
