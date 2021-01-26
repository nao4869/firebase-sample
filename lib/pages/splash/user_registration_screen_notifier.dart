import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserRegistrationScreenNotifier extends ChangeNotifier {
  UserRegistrationScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
    this.groupNotifier,
    this.userReference,
  }) {
    textController.text = '';
    groupTextController.text = '';
    profileFocusNode = FocusNode();
  }

  final formKey = GlobalKey<FormState>();
  final groupFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  final groupTextController = TextEditingController();
  final nameFieldFormKey = GlobalKey<FormState>();
  final groupFieldFormKey = GlobalKey<FormState>();
  final textFormHeight = 50.0;
  FocusNode profileFocusNode;

  bool isValid = false;
  bool isCodeValid = false;
  String name = '';
  String invitationCode = '';

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final CurrentGroupProvider groupNotifier;
  final UserReferenceProvider userReference;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  String onValidate(String text) {
    return null;
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    name = text;
    notifyListeners();
  }

  void onInvitationCodeChange(String text) {
    isCodeValid = text.isNotEmpty;
    invitationCode = text;
    profileFocusNode.requestFocus();
    notifyListeners();
  }

  /// 自己紹介編集 TextField 入力内容リセット
  void resetTextField() {
    onNameChange('');
    formKey.currentState.reset();
  }

  void navigateSplashScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => SplashScreen(
          userName: name,
          invitationCode: invitationCode,
        ),
      ),
    );
  }
}
