import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/device_id_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SplashScreenNotifier extends ChangeNotifier {
  SplashScreenNotifier({
    this.context,
    this.groupNotifier,
    this.userNotifier,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initialize();
    });
  }

  final BuildContext context;
  final CurrentGroupProvider groupNotifier;
  final UserReferenceProvider userNotifier;

  bool _isLoading = false;
  String _referenceToUser;
  bool _isDisplayCompletedTodo = false;
  String _groupId = '';
  String _deviceId;
  DocumentReference _userReference;
  QuerySnapshot _isUserExist;

  Future<void> initialize() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    final fireStoreInstance = FirebaseFirestore.instance;

    initDeviceId();
    await initUserReference();

    // TODO: 一度アプリを削除した際の処理をどうするか考慮する
    if (_isUserExist.size == 0 || _isUserExist == null) {
      // 初回起動時のみ、groupを追加
      fireStoreInstance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .add({
        'name': 'Group Name',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'deviceId': FieldValue.arrayUnion([_deviceId]),
      }).then((value) async {
        _userReference = await fireStoreInstance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .doc(value.id)
            .collection('users')
            .add({
          // Groupのサブコレクションに、Userを作成
          'name': 'UserName',
          'imagePath': null,
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'deviceId': FieldValue.arrayUnion([_deviceId]),
        });
        addUserSettings(value.id);

        // チュートリアルCategoryを追加
        final _reference = await fireStoreInstance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .doc(value.id)
            .collection('categories')
            .add({
          // Groupのサブコレクションに、Categoryを作成
          'name': 'Tutorial',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        // ProviderのグループIDを更新
        groupNotifier.updateGroupId(value.id);

        // ログイン中ユーザーへのReferenceを取得
        var userResult = await fireStoreInstance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .doc(value.id)
            .collection('users')
            .where('deviceId', arrayContains: _deviceId)
            .get();

        userResult.docs.forEach((res) {
          _referenceToUser = res.reference.id;
        });
        // ProviderのUser参照を更新
        userNotifier.updateUserReference(_referenceToUser);
        userNotifier.updateCompletedTodo(true);
        addTutorialTodoList(_reference);
      });
    } else {
      // 初回起動時以外に、deviceIdから該当するgroupIdを取得する
      var result = await fireStoreInstance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .where('deviceId', arrayContains: _deviceId)
          .get();
      result.docs.forEach((res) {
        _groupId = res.reference.id;
      });

      // ProviderのグループIDを更新
      groupNotifier.updateGroupId(_groupId);

      // ログイン中ユーザーへのReferenceを取得
      final userResult = await FirebaseFirestore.instance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .doc(_groupId)
          .collection('users')
          .where('deviceId', arrayContains: _deviceId)
          .get();

      userResult.docs.forEach((snapshot) {
        _referenceToUser = snapshot.reference.id;
      });

      String _userSettingsReference;
      final userSettingsReference = await FirebaseFirestore.instance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .doc(_groupId)
          .collection('users')
          .doc(_referenceToUser)
          .collection('userSettings')
          .get();
      userSettingsReference.docs.forEach((snapshot) {
        _userSettingsReference = snapshot.reference.id;
      });

      // ProviderのUser参照を更新
      userNotifier.updateUserReference(_referenceToUser);
      userNotifier.updateCompletedTodo(_isDisplayCompletedTodo);
      userNotifier.updateUserSettingsReference(_userSettingsReference);
    }
    if (groupNotifier.groupId != null && groupNotifier.groupId.isNotEmpty) {
      // ホーム画面遷移
      navigateHomeScreen();
    } else {
      _isLoading = false;
    }
  }

  // デバイスIDを設定
  void initDeviceId() {
    final deviceNotifier =
        Provider.of<DeviceIdProvider>(context, listen: false);
    if (Platform.isAndroid) {
      _deviceId = deviceNotifier.androidUid;
    } else {
      _deviceId = deviceNotifier.iosUid;
    }
  }

  // 初回ログイン判定
  void initUserReference() async {
    try {
      _isUserExist = await FirebaseFirestore.instance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .where('deviceId', arrayContains: _deviceId)
          .get();
    } catch (error) {
      debugPrint('Group id does not exist');
    }
  }

  void addUserSettings(String documentId) async {
    // UserSettingsコレクションを追加
    final reference = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(documentId)
        .collection('users')
        .doc(_userReference.id)
        .collection('userSettings')
        .add({
      // UserSettingsドキュメントを追加
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'displayCompletedTodo': true,
      'backgroundDesignId': 0,
      'backgroundImagePath': '',
    });
    userNotifier.updateUserSettingsReference(reference.id);
  }

  // 初回起動時にチュートリアルを追加
  void addTutorialTodoList(DocumentReference reference) {
    try {
      for (int i = 0; i < 3; i++) {
        reference.collection('to-dos').add({
          'name':
              AppLocalizations.of(context).translate('tutorialTodo${i + 1}'),
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'imagePath': null,
          'videoPath': null,
          'isChecked': false,
          'userImagePath': null,
        });
      }
    } catch (error) {
      debugPrint('Problem generating tutorial to-dos');
    }
  }

  void navigateHomeScreen() {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      HomeScreen.routeName,
    );
  }
}
