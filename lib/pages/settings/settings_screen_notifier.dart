import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/device_id_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/provider/withdrawal_status_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/settings/edit_user_icon_screen.dart';
import 'package:firebase_sample/pages/settings/edit_user_name_screen.dart';
import 'package:firebase_sample/pages/splash/user_registration_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/font_size_picker_bottom_sheet.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SettingsScreenNotifier extends ChangeNotifier {
  SettingsScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
    this.userNotifier,
  }) {
    screenSize = ScreenSize(
        size: MediaQuery.of(context).size,
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    sizeType = screenSize.specifyScreenSizeType();
    selectedFontSize = userNotifier.todoFontSize.toString();
    setFontSizeIndex();
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final UserReferenceProvider userNotifier;
  final ThemeProvider themeNotifier;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  ScreenSize screenSize;
  ScreenSizeType sizeType;
  bool _isWithdrawn = false;
  bool get getWithdrawStatus => _isWithdrawn;

  /// ピッカー用選択済み、選択候補アイテム
  String selectedFontSize = '13.0';
  int selectedFontSizeIndex = 0;

  // ダークモード切り替え関数
  void updateDarkMode(bool val) {
    themeNotifier.setThemeData = !val;
  }

  void navigateEditUserNameScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditUserNameScreen(),
      ),
    );
  }

  void navigateEditUserIconScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditUserIconScreen(),
      ),
    );
  }

  Future<void> navigateRegistrationScreen() async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => UserRegistrationScreen(),
      ),
    );
  }

  void updateIsDisplayCompletedTodo(
    bool displayCompletedTodo,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"displayCompletedTodo": displayCompletedTodo});

    // User Providerの値も更新
    userNotifier.updateCompletedTodo(displayCompletedTodo);
  }

  void updateIsDisplayOnlyCompletedTodo(
    bool isDisplayOnlyCompletedTodo,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"isDisplayOnlyCompletedTodo": isDisplayOnlyCompletedTodo});

    // User Providerの値も更新
    userNotifier.updateIsDisplayOnlyCompletedTodo(isDisplayOnlyCompletedTodo);
  }

  void updateIsSortByCreatedAt(bool isSortByCreatedAt) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"isSortByCreatedAt": isSortByCreatedAt});

    // User Providerの値も更新
    userNotifier.updateIsSortByCreatedAt(isSortByCreatedAt);
  }

  void updateIsSortCategoryByCreatedAt(bool isSortCategoryByCreatedAt) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"isSortCategoryByCreatedAt": isSortCategoryByCreatedAt});

    // User Providerの値も更新
    userNotifier.updateIsSortCategoryByCreatedAt(isSortCategoryByCreatedAt);
  }

  void updateIsDisplayCheckBox(bool isDisplayCheckBox) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"isDisplayCheckBox": isDisplayCheckBox});

    // User Providerの値も更新
    userNotifier.updateIsDisplayCheckBox(isDisplayCheckBox);
  }

  final List<String> items = [
    '13.0',
    '14.0',
    '15.0',
    '16.0',
    '17.0',
    '18.0',
    '19.0',
    '20.0',
  ];

  /// Notifier生成時に、カテゴリー名の文字サイズを初期化
  void setFontSizeIndex() {
    final size = userNotifier.todoFontSize;

    if (size == 13.0) {
      selectedFontSizeIndex = 0;
    } else if (size == 14.0) {
      selectedFontSizeIndex = 1;
    } else if (size == 15.0) {
      selectedFontSizeIndex = 2;
    } else if (size == 16.0) {
      selectedFontSizeIndex = 3;
    } else if (size == 17.0) {
      selectedFontSizeIndex = 4;
    } else if (size == 18.0) {
      selectedFontSizeIndex = 5;
    } else if (size == 19.0) {
      selectedFontSizeIndex = 6;
    } else {
      selectedFontSizeIndex = 7;
    }
  }

  void showModalPicker() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return FontSizePickerBottomSheet(
          onPressedDone: updateFireStoreTodoFontSize,
          onSelectedItemChanged: onSelectedFontSizeChanged,
          items: items,
          selectedIndex: selectedFontSizeIndex,
        );
      },
    );
  }

  /// ピーカー選択値変更関数
  void onSelectedFontSizeChanged(int index) {
    selectedFontSize = items[index];
    selectedFontSizeIndex = index;
    notifyListeners();
  }

  void updateFireStoreTodoFontSize() {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .update({"todoFontSize": num.parse(selectedFontSize)});

    // User Providerの値も更新
    userNotifier.updateTodoFontSize(num.parse(selectedFontSize));
    Navigator.of(context).pop();
  }

  Future<void> removeCurrentUserFromGroup() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final deviceNotifier =
        Provider.of<DeviceIdProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .update({
      'deviceIds': FieldValue.arrayRemove(
          [deviceNotifier.androidUid ?? deviceNotifier.iosUid])
    });
    await removeGroupOrRemoveUser();
  }

  Future<void> removeGroupOrRemoveUser() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final withdrawalStatusNotifier =
        Provider.of<WithdrawalStatusProvider>(context, listen: false);
    final groupReference = await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .get();

    _isWithdrawn = true;
    notifyListeners();

    // グループ内に他ユーザーが存在しない
    if (groupReference.data()['deviceIds'].length == 0) {
      withdrawalStatusNotifier.updateWithdrawalStatus(true);
      deleteExistingUserIconFile();
      deleteCurrentUserGroup();
      navigateRegistrationScreen();
    } else {
      // グループ内に別ユーザーが存在
      withdrawalStatusNotifier.updateWithdrawalStatus(true);
      deleteExistingUserIconFile();
      deleteCurrentUserSettingDocument();
      deleteCurrentUserDocument();
      navigateRegistrationScreen();
    }
  }

  Future<void> deleteCurrentUserGroup() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .delete();
  }

  Future<void> deleteCurrentUserDocument() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .delete();
  }

  Future<void> deleteCurrentUserSettingDocument() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('users')
        .doc(userNotifier.referenceToUser)
        .collection('userSettings')
        .doc(userNotifier.userSettingsReference)
        .delete();
  }

  Future<bool> removeAccountDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return CmnDialog(context).showDialogWidget(
          onPositiveCallback: confirmDeleteAccount,
          titleStr: AppLocalizations.of(context).translate('deleteAccount'),
          titleColor: switchAppThemeNotifier.currentTheme,
          msgStr: AppLocalizations.of(context)
              .translate('deleteAccountDescription'),
          positiveBtnStr:
              AppLocalizations.of(context).translate('proceedToDelete'),
          negativeBtnStr: AppLocalizations.of(context).translate('cancel'),
        );
      },
    );
  }

  Future<bool> confirmDeleteAccount() {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return CmnDialog(context).showWithdrawDialogWidget(
          onPositiveCallback: removeCurrentUserFromGroup,
          titleStr: AppLocalizations.of(context).translate('confirmation'),
          titleColor: switchAppThemeNotifier.currentTheme,
          msgStr:
              AppLocalizations.of(context).translate('confirmDeleteAccount'),
          positiveBtnStr:
              AppLocalizations.of(context).translate('proceedToDelete'),
          negativeBtnStr: AppLocalizations.of(context).translate('cancel'),
        );
      },
    );
  }

  Future<void> deleteExistingUserIconFile() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
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
}
