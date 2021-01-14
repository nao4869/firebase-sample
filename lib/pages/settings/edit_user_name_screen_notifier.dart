import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;

import '../../app_localizations.dart';

class EditUserNameScreenNotifier extends ChangeNotifier {
  EditUserNameScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
    this.groupNotifier,
    this.userReference,
  }) {
    textController.text = '';
    profileFocusNode = FocusNode();

    // ログイン中ユーザー名を取得
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var document = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .doc('${userReference.referenceToUser}');

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

  File _image;
  String _uploadedFileURL;

  bool isValid = false;
  String name = '';
  File image;

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final CurrentGroupProvider groupNotifier;
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
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(notifier.referenceToUser)
        .update({"name": name});
    Navigator.of(context).pop();
  }

  // FireStoreの該当ユーザー画像を更新
  // Todo: 該当ユーザーへのReferenceをProviderで保持する
//  void updateUserProfileImage() async {
//    final notifier = Provider.of<UserReferenceProvider>(context, listen: false);
//    final groupNotifier =
//        Provider.of<CurrentGroupProvider>(context, listen: false);
//    _image = await ImagePicker.pickImage(
//      source: ImageSource.gallery,
//      maxHeight: 600,
//      maxWidth: 600,
//    );
//
//    firebase_storage.Reference storageReference = firebase_storage
//        .FirebaseStorage.instance
//        .ref()
//        .child('images/${Path.basename(_image.path)}}');
//    await storageReference.putFile(_image);
//
//    storageReference.getDownloadURL().then((fileURL) {
//      _uploadedFileURL = fileURL;
//
//      FirebaseFirestore.instance
//          .collection('groups')
//          .doc(groupNotifier.groupId)
//          .collection('users')
//          .doc(notifier.referenceToUser)
//          .update({'imagePath': _uploadedFileURL});
//    });
//    notifyListeners();
//  }
}
