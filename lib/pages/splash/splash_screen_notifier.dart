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
  String _groupId = '';

  Future<void> initialize() async {
    if (_isLoading) {
      return;
    }

    final deviceNotifier =
        Provider.of<DeviceIdProvider>(context, listen: false);
    _isLoading = true;

    final fireStoreInstance = FirebaseFirestore.instance;
    String _deviceId;
    if (Platform.isAndroid) {
      _deviceId = deviceNotifier.androidUid;
    } else {
      _deviceId = deviceNotifier.iosUid;
    }

    var isUserExist;
    try {
      isUserExist = await FirebaseFirestore.instance
          .collection('groups')
          .where('deviceId', arrayContains: _deviceId)
          .get();
    } catch (error) {
      debugPrint('Group id does not exist');
    }

    // TODO: 一度アプリを削除した際の処理をどうするか考慮する
    if (isUserExist.size == 0 || isUserExist == null) {
      // 初回起動時のみ、groupを追加
      fireStoreInstance.collection('groups').add({
        'name': 'Group Name',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'deviceId': FieldValue.arrayUnion([_deviceId]),
      }).then((value) async {
        fireStoreInstance
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

        final reference = await fireStoreInstance
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
        var userResult = await FirebaseFirestore.instance
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
        addTutorialTodoList(reference);
      });
    } else {
      // 初回起動時以外に、deviceIdから該当するgroupIdを取得する
      var result = await FirebaseFirestore.instance
          .collection('groups')
          .where('deviceId', arrayContains: _deviceId)
          .get();
      result.docs.forEach((res) {
        _groupId = res.reference.id;
      });

      // ProviderのグループIDを更新
      groupNotifier.updateGroupId(_groupId);

      // ログイン中ユーザーへのReferenceを取得
      var userResult = await FirebaseFirestore.instance
          .collection('groups')
          .doc(_groupId)
          .collection('users')
          .where('deviceId', arrayContains: _deviceId)
          .get();

      userResult.docs.forEach((res) {
        _referenceToUser = res.reference.id;
      });
      // ProviderのUser参照を更新
      userNotifier.updateUserReference(_referenceToUser);
    }
    if (groupNotifier.groupId != null && groupNotifier.groupId.isNotEmpty) {
      // ホーム画面遷移
      navigateHomeScreen();
    } else {
      _isLoading = false;
    }
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
