import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class EditUserNameScreenNotifier extends ChangeNotifier {
  EditUserNameScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
    this.userReference,
  }) {
    textController.text = '';
    profileFocusNode = FocusNode();

    // ログイン中ユーザー名を取得
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var document = Firestore.instance
          .collection('users')
          .document('${userReference.referenceToUser.documentID}');

      document.get().then((doc) {
        textController.text = doc['name'].toString();
        textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length));
      });
    });
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
  final UserReferenceProvider userReference;
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

  // FireStoreの該当ユーザー名を更新
  // Todo: 該当ユーザーへのReferenceをProviderで保持する
  void updateUserName() {
    final notifier = Provider.of<UserReferenceProvider>(context, listen: false);
    Firestore.instance
        .collection('users')
        .document(notifier.referenceToUser.documentID)
        .updateData({"name": name});
    Navigator.of(context).pop();
  }
}
