import 'dart:io';

import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';

class EditUserNameScreenNotifier extends ChangeNotifier {
  EditUserNameScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
  }) {
    textController.text = '';
    profileFocusNode = FocusNode();
  }

  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  final nameFieldFormKey = GlobalKey<FormState>();
  final textFormHeight = 50.0;
  FocusNode profileFocusNode;

  bool isValid = false;
  String name = '';
  File image;

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  String onValidate(String text) {
    if (text.isEmpty) {
      return AppLocalizations.of(context).translate('emptyInput');
    }
    return null;
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    name = text;
  }

  /// 自己紹介編集　TextField 変更時処理
  void onChange(String text) {
    name = text;
    profileFocusNode.requestFocus();
    // isValid = resultType == SelfIntroductionValidationResultType.ok;
    notifyListeners();
  }

  /// 自己紹介編集 TextField 入力内容リセット
  void resetTextField() {
    onChange('');
    formKey.currentState.reset();
  }
}
