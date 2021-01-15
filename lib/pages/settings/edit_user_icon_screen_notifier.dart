import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;

class EditUserIconScreenNotifier extends ChangeNotifier {
  EditUserIconScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
    this.groupNotifier,
    this.userReference,
  }) {
    // ログイン中ユーザー名を取得
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var document = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .doc('${userReference.referenceToUser}');

      document.get().then((doc) {
        imagePath = doc['imagePath'].toString();
      });
    });
  }

  String imagePath;
  String _name = '';
  String _uploadedFileURL;
  File _image;

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final CurrentGroupProvider groupNotifier;
  final UserReferenceProvider userReference;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

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
        .update({"name": _name});
    Navigator.of(context).pop();
  }

  // FireStoreの該当ユーザー画像を更新
  // Todo: 該当ユーザーへのReferenceをProviderで保持する
  void updateUserProfileImage() async {
    final notifier = Provider.of<UserReferenceProvider>(context, listen: false);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    _image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
    );

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image.path)}}');
    await storageReference.putFile(_image);

    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;

      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .doc(notifier.referenceToUser)
          .update({'imagePath': _uploadedFileURL});
    });
    notifyListeners();
  }
}
