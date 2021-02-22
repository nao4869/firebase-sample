import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/settings/edit_user_icon_screen.dart';
import 'package:firebase_sample/pages/settings/edit_user_name_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/font_size_picker_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final UserReferenceProvider userNotifier;
  final ThemeProvider themeNotifier;
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  ScreenSize screenSize;
  ScreenSizeType sizeType;

  /// ピッカー用選択済み、選択候補アイテム
  String selectedFontSize = '14.0';
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

  final List<String> items = [
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
    if (size == 15.0) {
      selectedFontSizeIndex = 0;
    } else if (size == 16.0) {
      selectedFontSizeIndex = 1;
    } else if (size == 17.0) {
      selectedFontSizeIndex = 2;
    } else if (size == 18.0) {
      selectedFontSizeIndex = 3;
    } else if (size == 19.0) {
      selectedFontSizeIndex = 4;
    } else {
      selectedFontSizeIndex = 5;
    }
  }

  void showModalPicker() {
    final userSettingsNotifier =
        Provider.of<UserReferenceProvider>(context, listen: false);
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return FontSizePickerBottomSheet(
          onPressedDone: () {
            userSettingsNotifier
                .updateTodoFontSize(num.parse(selectedFontSize));
            Navigator.of(context).pop();
          },
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
}
