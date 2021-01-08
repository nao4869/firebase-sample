import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:firebase_sample/pages/setting_row.dart';
import 'package:firebase_sample/pages/settings_screen_notifier.dart';
import 'package:firebase_sample/pages/switch_application_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  static String routeName = 'settings-screen';

  const SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        themeNotifier: Provider.of(context, listen: false),
      ),
      child: _SettingsScreen(),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.isLightTheme ? white : darkBlack,
      appBar: AppBar(
        backgroundColor: switchAppThemeNotifier.currentTheme,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            ...buildProfileSection(context),
            const SizedBox(height: 20),
            ...buildAppSettingsSection(context),
            const SizedBox(height: 30)
          ],
        ),
      ),
    );
  }

  List<Widget> buildProfileSection(BuildContext context) {
    final notifier = Provider.of<SettingsScreenNotifier>(context);
    return [
      SettingTitle(
        title: AppLocalizations.of(context).translate('accountSettings'),
      ),
      // ダークモードの切り替え - データベース更新
      SettingRow(
        title: AppLocalizations.of(context).translate('darkMode'),
        isEnable: notifier.themeNotifier.darkMode,
        onChange: notifier.updateDarkMode,
      ),
    ];
  }

  List<Widget> buildAppSettingsSection(BuildContext context) {
    return [
      SettingTitle(
        title: AppLocalizations.of(context).translate('editAppTheme'),
      ),
      SettingRow(
        title: AppLocalizations.of(context).translate('editDesignTheme'),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => SwitchApplicationTheme(),
            ),
          );
        },
      ),
    ];
  }
}
