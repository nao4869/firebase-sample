import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/settings/edit_user_icon_screen.dart';
import 'package:firebase_sample/pages/settings/edit_user_name_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreenNotifier extends ChangeNotifier {
  SettingsScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
    this.userNotifier,
  }) {
    //
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final UserReferenceProvider userNotifier;
  final ThemeProvider themeNotifier;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  // ダークモード切り替え関数
  void updateDarkMode(bool val) {
    themeNotifier.setThemeData = !val;
  }

  void navigateEditUserNameScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditUserNameScreen(),
      ),
    );
  }

  void navigateEditUserIconScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditUserIconScreen(),
      ),
    );
  }

  void updateIsDisplayCompletedTodo(
    bool displayCompletedTodo,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"displayCompletedTodo": displayCompletedTodo});

    // User Providerの値も更新
    userNotifier.updateCompletedTodo(displayCompletedTodo);
  }

  void updateIsSortByCreatedAt(bool isSortByCreatedAt) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"isSortByCreatedAt": isSortByCreatedAt});

    // User Providerの値も更新
    userNotifier.updateIsSortByCreatedAt(isSortByCreatedAt);
  }

  void updateIsSortCategoryByCreatedAt(bool isSortCategoryByCreatedAt) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"isSortCategoryByCreatedAt": isSortCategoryByCreatedAt});

    // User Providerの値も更新
    userNotifier.updateIsSortCategoryByCreatedAt(isSortCategoryByCreatedAt);
  }
}
