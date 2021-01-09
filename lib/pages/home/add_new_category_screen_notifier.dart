import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCategoryScreenNotifier extends ChangeNotifier {
  AddCategoryScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
  }) {
    /// Notifier生成時に、ログインユーザーを取得
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;

  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  String taskName;
  int currentTabIndex = 0;
  int initPosition = 0;
  int selectedColorIndex = 0;
  bool isValid = false;

  void pop() {
    Navigator.of(context).pop();
  }

  void onSelectedColorChange(
    int index,
  ) {
    selectedColorIndex = index;
    notifyListeners();
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    taskName = text;
    notifyListeners();
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    taskName = '';
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void navigateAddCategoryScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => AddCategoryScreen(),
      ),
    );
  }

  /// カテゴリーを追加する関数
  /// colorのみ指定し、タスク名を追加は行わない
  void addCategory() {
//    final categoryNotifier =
//    Provider.of<CategoryProvider>(context, listen: false);
//    final db = Provider.of<DataBaseProvider>(context, listen: false);
//    final dbInstance = db.getDatabaseInfo();

//    final category = Category(
//      id: categoryNotifier.categoriesList.length,
//      name: '',
//      colorNumber: selectedColorIndex,
//    );
//    categoryNotifier.addCategory(category);
//    db.insertCategory(category, dbInstance);
    notifyListeners();
  }

  /// カテゴリーを追加する関数
  /// colorのみ指定し、タスク名を追加は行わない
  void addCategoryName(
      //Category selectedCategory,
      ) {
//    final categoryNotifier =
//    Provider.of<CategoryProvider>(context, listen: false);
//    final db = Provider.of<DataBaseProvider>(context, listen: false);
//    final dbInstance = db.getDatabaseInfo();
//
//    final category = Category(
//      id: selectedCategory.id,
//      name: taskName,
//      colorNumber: selectedCategory.colorNumber,
//    );
//
//    categoryNotifier.updateCategory(category.id, category);
//    db.updateCategory(category, dbInstance);
//    taskName = '';
//    notifyListeners();
  }

  // カテゴリー編集、削除用のダイアログ
  void editCategory() {
//    CmnDialog(context).showThreeButtonsDialog(
//      onFirstCallback: onFirstButtonPressed,
//      firstBtnStr: '編集する',
//      onSecondCallback: () {
////        db.deleteCategory(selectedCategory.id);
////        categoryNotifier.deleteCategory(selectedCategory.id);
//
//        CmnDialog(context).showConfirmDialog(
//          msgStr: 'カテゴリーが削除されました',
//          confirmBtnStr: okay,
//          onConfirmCallback: null,
//          btnTextColor: white,
//          btnBgColor: switchAppThemeNotifier.currentTheme,
//        );
//      },
//      secondBtnStr: '削除する',
//      onLastCallback: () {},
//      lastBtnStr: 'キャンセル',
//      titleStr: selectedCategory.name,
//      titleColor: switchAppThemeNotifier.currentTheme,
//    );
  }
}
