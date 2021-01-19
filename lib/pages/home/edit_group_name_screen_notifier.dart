import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/settings/edit_user_icon_screen.dart';
import 'package:firebase_sample/pages/settings/edit_user_name_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditGroupNameScreenNotifier extends ChangeNotifier {
  EditGroupNameScreenNotifier({
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

  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  String groupName;
  bool isValid = false;

  // ダークモード切り替え関数
  void updateDarkMode(bool val) {
    themeNotifier.setThemeData = !val;
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    groupName = text;
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    groupName = '';
    notifyListeners();
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

  void updateGroupName() {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .update({'name': groupName});
  }
}
