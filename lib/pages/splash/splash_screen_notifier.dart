import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/device_id_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenNotifier extends ChangeNotifier {
  SplashScreenNotifier({
    this.context,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initialize();
    });
  }

  bool _isLoading = false;
  String _referenceToUser;
  String _groupId = '';

  final BuildContext context;

  Future<void> initialize() async {
    if (_isLoading) {
      return;
    }

    final deviceNotifier =
        Provider.of<DeviceIdProvider>(context, listen: false);
    _isLoading = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('isInitial');

    String _deviceId;
    if (Platform.isAndroid) {
      _deviceId = deviceNotifier.androidUid;
    } else {
      _deviceId = deviceNotifier.iosUid;
    }

    // TODO: 一度アプリを削除した際の処理をどうするか考慮する
    if (firstTime == null || firstTime) {
      // 初回起動時のみ、groupを追加
      final fireStoreInstance = FirebaseFirestore.instance;
      fireStoreInstance.collection('groups').add({
        'name': 'Group Name',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'deviceId': FieldValue.arrayUnion([_deviceId]),
      }).then((value) {
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

        fireStoreInstance
            .collection('groups')
            .doc(value.id)
            .collection('categories')
            .add({
          // Groupのサブコレクションに、Categoryを作成
          'name': 'Tutorial',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        _groupId = value.id;
      });
      prefs.setBool('isInitial', false);
    } else {
      // 初回起動時以外に、deviceIdから該当するgroupIdを取得する
      var result = await FirebaseFirestore.instance
          .collection('groups')
          .where('deviceId', arrayContains: _deviceId)
          .get();
      result.docs.forEach((res) {
        _groupId = res.reference.id;
      });
    }
    // ProviderのグループIDを更新
    Provider.of<CurrentGroupProvider>(context, listen: false)
        .updateGroupId(_groupId);

    // ログイン中ユーザーへのReferenceを取得
    var result = await FirebaseFirestore.instance
        .collection('groups')
        .doc(_groupId)
        .collection('users')
        .where('deviceId', isEqualTo: _deviceId)
        .get();

    result.docs.forEach((res) {
      _referenceToUser = res.reference.id;
    });
    // ProviderのUser参照を更新
    Provider.of<UserReferenceProvider>(context, listen: false)
        .updateUserReference(_referenceToUser);

    _isLoading = true;
    // ホーム画面遷移
    navigateHomeScreen();
  }

  void navigateHomeScreen() {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      HomeScreen.routeName,
    );
  }
}
