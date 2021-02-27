import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
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
    screenSize = ScreenSize(
        size: MediaQuery.of(context).size,
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    sizeType = screenSize.specifyScreenSizeType();
    iconsRowWidthByDevice = setIconsRowWidthByDeviceSize();
    iconsRowHeightByDevice = setIconsRowHeightByDeviceSize();
  }

  String _uploadedFileURL;
  File _image;
  bool isUploadingImage = false;
  double iconsRowWidthByDevice;
  double iconsRowHeightByDevice;

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final CurrentGroupProvider groupNotifier;
  final UserReferenceProvider userReference;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  ScreenSize screenSize;
  ScreenSizeType sizeType;

  // FireStoreの該当ユーザー画像を更新
  // Todo: 該当ユーザーへのReferenceをProviderで保持する
  void updateUserProfileImage() async {
    final notifier = Provider.of<UserReferenceProvider>(context, listen: false);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);

    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }

    if (_image != null) {
      await deleteExistingUserIconFile();
      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(
              'user_images/${groupNotifier.groupId}/${userReference.referenceToUser}/${Path.basename(_image.path)}');
      isUploadingImage = true;
      notifyListeners();
      await storageReference.putFile(_image);

      storageReference.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;

        FirebaseFirestore.instance
            .collection('versions')
            .doc('v2')
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

  Future<void> deleteExistingUserIconFile() async {
    final notifier = Provider.of<UserReferenceProvider>(context, listen: false);
    final userReference = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(notifier.referenceToUser)
        .get();

    if (userReference.data()['imagePath'] != null &&
        !(userReference.data()['imagePath'].toString().contains('assets'))) {
      final firebase_storage.Reference existingImageStoragePath =
          firebase_storage.FirebaseStorage.instance
              .refFromURL(userReference.data()['imagePath']);

      await existingImageStoragePath.delete();
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
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(notifier.referenceToUser)
        .update({'imagePath': path});
    notifyListeners();
  }

  double setIconsRowWidthByDeviceSize() {
    if (sizeType == ScreenSizeType.large) {
      return 70;
    } else if (sizeType == ScreenSizeType.xxlarge) {
      return 75;
    } else {
      return 90;
    }
  }

  double setIconsRowHeightByDeviceSize() {
    if (sizeType == ScreenSizeType.large) {
      return 80;
    } else if (sizeType == ScreenSizeType.xxlarge) {
      return 80;
    } else {
      return 100;
    }
  }
}
