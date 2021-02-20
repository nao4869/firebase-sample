import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/splash/splash_screen.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';

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

    screenSize = ScreenSize(
        size: MediaQuery.of(context).size,
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    sizeType = screenSize.specifyScreenSizeType();
  }

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

  ScreenSize screenSize;
  ScreenSizeType sizeType;

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
    groupFormKey.currentState.reset();
  }

  void checkInvitationCodeValidity() async {
    final fireStoreInstance = FirebaseFirestore.instance;
    if (invitationCode.isNotEmpty) {
      final documentReference = await fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(invitationCode)
          .get();
      if (documentReference.exists) {
        navigateSplashScreen(true);
      } else {
        showDialog<bool>(
          context: context,
          builder: (_) {
            return CmnDialog(context).showDialogWidget(
              onPositiveCallback: () {},
              onNegativeCallback: () {
                navigateSplashScreen(false);
              },
              titleStr: AppLocalizations.of(context).translate('invalidCode'),
              titleColor: switchAppThemeNotifier.currentTheme,
              msgStr: AppLocalizations.of(context)
                  .translate('invalidInvitationCode'),
              positiveBtnStr: cmnOkay,
              negativeBtnStr: AppLocalizations.of(context)
                  .translate('registerWithoutInvitationCode'),
            );
          },
        );
      }
    } else {
      navigateSplashScreen(false);
    }
  }

  void navigateSplashScreen(bool isInvitedUser) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => SplashScreen(
          userName: name,
          invitationCode: isInvitedUser ? invitationCode : null,
        ),
      ),
    );
  }
}
