import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/settings/select_design_screen.dart';
import 'package:firebase_sample/pages/settings/setting_row.dart';
import 'package:firebase_sample/pages/settings/settings_screen_notifier.dart';
import 'package:firebase_sample/pages/settings/switch_application_theme.dart';
import 'package:firebase_sample/widgets/stream/switch_toggle_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

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
        userNotifier: Provider.of(context, listen: false),
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
      backgroundColor: theme.isLightTheme ? themeColor : darkBlack,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: switchAppThemeNotifier.currentTheme,
        title: Text(
          'User Settings',
          style: TextStyle(
            color: white,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        title: AppLocalizations.of(context).translate('editUserName'),
        onTap: notifier.navigateEditUserNameScreen,
      ),
      SettingRow(
        title: AppLocalizations.of(context).translate('editUserIcon'),
        onTap: notifier.navigateEditUserIconScreen,
      ),
      SettingRow(
        title: AppLocalizations.of(context).translate('authenticatePhone'),
        onTap: () {},
      ),
    ];
  }

  List<Widget> buildAppSettingsSection(BuildContext context) {
    final notifier = Provider.of<SettingsScreenNotifier>(context);
    return [
      SettingTitle(
        title: AppLocalizations.of(context).translate('accountSettings'),
      ),
      SettingRow(
        title: AppLocalizations.of(context).translate('editAppTheme'),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => SwitchApplicationTheme(),
            ),
          );
        },
      ),
      SettingRow(
        title: AppLocalizations.of(context).translate('editDesignTheme'),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => SelectDesignScreen(),
            ),
          );
        },
      ),
      SwitchToggleListTile(
        switchFieldName: 'displayCompletedTodo',
        onChanged: (bool value) {
          notifier.updateIsDisplayCompletedTodo(value);
        },
      ),
      SwitchToggleListTile(
        switchFieldName: 'isSortByCreatedAt',
        onChanged: (bool value) {
          notifier.updateIsSortByCreatedAt(value);
        },
      ),
    ];
  }
}
