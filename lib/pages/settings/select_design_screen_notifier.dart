import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectDesignScreenNotifier extends ChangeNotifier {
  SelectDesignScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.groupNotifier,
    this.userReferenceNotifier,
  }) {
    screenSize = ScreenSize(
      size: MediaQuery.of(context).size,
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
    sizeType = screenSize.specifyScreenSizeType();
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final CurrentGroupProvider groupNotifier;
  final UserReferenceProvider userReferenceNotifier;

  ScreenSize screenSize;
  ScreenSizeType sizeType;

  // FireStoreの該当ユーザー画像を更新
  // Assets内の画像を適用
  void updateThemeColor(
    int backgroundDesignId,
    String imagePath,
  ) async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);

    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userReferenceNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userReferenceNotifier.userSettingsReference)
        .update({
      "backgroundDesignId": backgroundDesignId,
      "backgroundImagePath": imagePath,
    });
    switchAppThemeNotifier.updateSelectedImagePath(imagePath);
    notifyListeners();
  }

  void popDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
