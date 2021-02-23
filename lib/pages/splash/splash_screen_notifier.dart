import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/provider/device_id_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SplashScreenNotifier extends ChangeNotifier {
  SplashScreenNotifier({
    this.context,
    this.switchAppThemeProvider,
    this.groupNotifier,
    this.parentCategoryIdNotifier,
    this.userNotifier,
    this.userName,
    this.invitationCode,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initialize();
    });
  }

  final String userName;
  final String invitationCode;
  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeProvider;
  final CurrentGroupProvider groupNotifier;
  final CurrentParentCategoryIdProvider parentCategoryIdNotifier;
  final UserReferenceProvider userNotifier;

  bool _isRegistrationProcess = false;
  bool _isLoading = false;
  String _referenceToUser;
  String _selectedImagePath;
  String _fcmToken;
  bool _isDisplayCompletedTodo = false;
  bool _isDisplayOnlyCompletedTodo = false;
  bool _isSortByCreatedAt = false;
  bool _isSortCategoryByCreatedAt = false;
  bool _isRegistrationCompleted = false;
  double _todoFontSize = 13.0;
  String _groupId = '';
  String _parentCategoryId = '';
  String _deviceId;
  DocumentReference _userReference;
  QuerySnapshot _isUserExist;

  Future<void> initialize() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    initDeviceId();

    await getFcmToken();

    // ユーザー登録済み判定、非同期で取得する為、await必須
    await initUserReference();

    // TODO: 一度アプリを削除した際の処理をどうするか考慮する
    if (_isUserExist.size == 0 || _isUserExist == null) {
      if (invitationCode != null && invitationCode.isNotEmpty) {
        invitedUserRegistration();
      } else {
        initialUserRegistration();
      }
    } else {
      singIn();
    }
    if (groupNotifier.groupId != null && groupNotifier.groupId.isNotEmpty) {
      // ホーム画面遷移
      navigateHomeScreen();
    } else {
      _isLoading = false;
    }
  }

  Future<void> getFcmToken() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      debugPrint("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _fcmToken = token;
    });
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
  Future<void> initUserReference() async {
    try {
      _isUserExist = await FirebaseFirestore.instance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .where('deviceIds', arrayContains: _deviceId)
          .get();
    } catch (error) {
      debugPrint('Group id does not exist');
    }
  }

  // 招待コードを所持しているケース
  void invitedUserRegistration() async {
    final fireStoreInstance = FirebaseFirestore.instance;

    if (!_isRegistrationProcess) {
      _isRegistrationProcess = true;

      // 端末のデバイスIDをサブコレクションへ追加
      fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(invitationCode)
          .update({
        'deviceIds': FieldValue.arrayUnion([_deviceId])
      });

      // 初回起動時のみ、groupを追加
      final referenceToUser = await fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(invitationCode)
          .collection('users')
          .add({
        'name': userName ?? 'UserName',
        'imagePath': null,
        'fcmToken': _fcmToken,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'deviceId': _deviceId,
      });
      // ProviderのグループIDを更新
      groupNotifier.updateGroupId(invitationCode);

      // ProviderのUser参照を更新
      userNotifier.updateUserReference(referenceToUser.id);
      userNotifier.updateCompletedTodo(true);

      // UserSettingsを初期化
      addUserSettings(
        groupId: invitationCode,
        userId: referenceToUser.id,
      );
    }
  }

  // 招待なし、初回登録処理関数
  void initialUserRegistration() {
    // 複数回実行されてしまう問題を修正
    if (_isRegistrationCompleted) {
      return;
    }

    final fireStoreInstance = FirebaseFirestore.instance;
    // 初回起動時のみ、groupを追加
    fireStoreInstance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .add({
      'name': 'Group Name',
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'deviceIds': FieldValue.arrayUnion([_deviceId]),
    }).then((value) async {
      // groupsのサブコレクションに、Userを作成
      _userReference = await fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(value.id)
          .collection('users')
          .add({
        'name': 'UserName',
        'imagePath': null,
        'fcmToken': _fcmToken,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'deviceId': _deviceId,
      });

      // groupsのサブコレクションに、deviceIdを追加
      fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(value.id)
          .collection('deviceIds')
          .add({
        'id': _deviceId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      // チュートリアルCategoryを追加
      fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(value.id)
          .collection('categories')
          .add({
        'name': AppLocalizations.of(context).translate('tutorial'),
        'createdAt': Timestamp.fromDate(DateTime.now()),
      }).then((parent) async {
        final _reference = await fireStoreInstance
            .collection('versions')
            .doc('v2')
            .collection('groups')
            .doc(value.id)
            .collection('categories')
            .doc(parent.id)
            .collection('children')
            .add({
          'name': AppLocalizations.of(context).translate('tutorial'),
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        // Providerの親カテゴリーIDを更新
        parentCategoryIdNotifier.updateCurrentParentCategoryId(parent.id);
        addTutorialTodoList(_reference);

        addUserSettings(
          groupId: value.id,
          parentCategoryId: parent.id,
          userId: _userReference.id,
        );
      });

      // ProviderのグループIDを更新
      groupNotifier.updateGroupId(value.id);

      // ログイン中ユーザーへのReferenceを取得
      var userResult = await fireStoreInstance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(value.id)
          .collection('users')
          .where('deviceId', isEqualTo: _deviceId)
          .get();

      userResult.docs.forEach((res) {
        _referenceToUser = res.reference.id;
      });
      // ProviderのUser参照を更新
      userNotifier.updateUserReference(_referenceToUser);
      userNotifier.updateCompletedTodo(true);
    });
  }

  // 再起動時、2回目以降ログイン処理
  void singIn() async {
    if (_isRegistrationCompleted) {
      return;
    }

    final fireStoreInstance = FirebaseFirestore.instance;
    // 初回起動時以外に、deviceIdから該当するgroupIdを取得する
    // TODO: groupIdの存在を確認
    var result = await fireStoreInstance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .where('deviceIds', arrayContains: _deviceId)
        .get();
    result.docs.forEach((res) {
      _groupId = res.reference.id;
    });

    // ProviderのグループIDを更新
    groupNotifier.updateGroupId(_groupId);

    // ログイン中ユーザーへのReferenceを取得
    final userResult = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(_groupId)
        .collection('users')
        .where('deviceId', isEqualTo: _deviceId)
        .get();

    userResult.docs.forEach((snapshot) {
      _referenceToUser = snapshot.reference.id;
    });

    String _userSettingsReference;
    String _parentCategoryId;
    final userSettingsReference = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(_groupId)
        .collection('users')
        .doc(_referenceToUser)
        .collection('userSettings')
        .get();
    userSettingsReference.docs.forEach((snapshot) {
      _userSettingsReference = snapshot.reference.id;
      _parentCategoryId = snapshot.data()['currentParentCategoryId'];
      _selectedImagePath = snapshot.data()['backgroundImagePath'];
      _isDisplayCompletedTodo = snapshot.data()['displayCompletedTodo'];
      _isDisplayOnlyCompletedTodo =
          snapshot.data()['isDisplayOnlyCompletedTodo'];
      _isSortByCreatedAt = snapshot.data()['isSortByCreatedAt'];
      _isSortCategoryByCreatedAt = snapshot.data()['isSortCategoryByCreatedAt'];
      _todoFontSize = snapshot.data()['todoFontSize'];
    });

    parentCategoryIdNotifier.updateCurrentParentCategoryId(_parentCategoryId);
    userNotifier.initializeUserSettings(
      userReference: _referenceToUser,
      userSettingsReference: _userSettingsReference,
      isDisplayCompletedTodo: _isDisplayCompletedTodo,
      isDisplayOnlyCompletedTodo: _isDisplayOnlyCompletedTodo,
      isSortByCreatedAt: _isSortByCreatedAt,
      isSortCategoryByCreatedAt: _isSortCategoryByCreatedAt,
      todoFontSize: _todoFontSize,
      currentParentCategoryIdReference: _parentCategoryId,
    );

    // 設定中の背景色がある際には、Providerで保持する
    switchAppThemeProvider.updateSelectedImagePath(_selectedImagePath);
    _isRegistrationCompleted = true;
  }

  // ユーザー設定コレクションを初期化 - 初回ログイン、招待初回登録時実行
  void addUserSettings({
    String groupId,
    String parentCategoryId,
    String userId,
  }) async {
    // UserSettingsコレクションを追加
    final reference = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupId)
        .collection('users')
        .doc(userId)
        .collection('userSettings')
        .add({
      // UserSettingsドキュメントを追加
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'displayCompletedTodo': true,
      'isDisplayOnlyCompletedTodo': false,
      'isSortByCreatedAt': true,
      'isSortCategoryByCreatedAt': true,
      'todoFontSize': 13.0,
      'backgroundDesignId': 0,
      'backgroundImagePath': '',
      'currentParentCategoryId': parentCategoryId,
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
          'remindDate': null,
          'imagePath': null,
          'videoPath': null,
          'isChecked': false,
          'taggedUserReference': null,
        });
      }
    } catch (error) {
      debugPrint('Problem generating tutorial to-dos');
    }
    _isRegistrationCompleted = true;
  }

  void navigateHomeScreen() {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      HomeScreen.routeName,
    );
  }
}
