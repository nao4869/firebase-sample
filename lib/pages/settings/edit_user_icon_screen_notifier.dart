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
  });

  String _uploadedFileURL;
  File _image;
  bool isUploadingImage = false;

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final CurrentGroupProvider groupNotifier;
  final UserReferenceProvider userReference;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

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

    if (_image != null) {
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(_image.path)}}');
      isUploadingImage = true;
      notifyListeners();
      await storageReference.putFile(_image);

      storageReference.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;

        FirebaseFirestore.instance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .doc(groupNotifier.groupId)
            .collection('users')
            .doc(notifier.referenceToUser)
            .update({'imagePath': _uploadedFileURL});
        isUploadingImage = false;
        notifyListeners();
      });
    }
  }

  // FireStoreの該当ユーザー画像を更新
  // Assets内の画像を適用
  void updateUserAssetProfile(String path) async {
    final notifier = Provider.of<UserReferenceProvider>(context, listen: false);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);

    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(notifier.referenceToUser)
        .update({'imagePath': path});
    notifyListeners();
  }
}
