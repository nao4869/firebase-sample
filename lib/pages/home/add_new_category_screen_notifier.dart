import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/add_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/bottom_sheet/edit_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

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

  Future<void> displayActionSheet({
    String collection,
    String documentId,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context).translate('edit'),
                style: TextStyle(
                  color: switchAppThemeNotifier.currentTheme,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                editCategory(
                  collection: collection,
                  documentId: documentId,
                  initialValue: taskName,
                );
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context).translate('doDelete'),
                style: TextStyle(
                  color: switchAppThemeNotifier.currentTheme,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteConfirmDialog(
                  collection,
                  documentId,
                );
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              AppLocalizations.of(context).translate('cancel'),
              style: TextStyle(
                color: switchAppThemeNotifier.currentTheme,
              ),
            ),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  /// カテゴリーを追加する関数
  /// colorのみ指定し、タスク名を追加は行わない
  void addCategory() {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    Navigator.of(context).pop();
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .add({
      // Groupのサブコレクションに、Categoryを作成
      'name': taskName,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    notifyListeners();
  }

  void deleteConfirmDialog(
    String collection,
    String documentId,
  ) {
    CmnDialog(context).showYesNoDialog(
      onPositiveCallback: () {
        deleteCategory(
          collection,
          documentId,
        );
        deleteCategoryTodoList(documentId);
      },
      titleStr: AppLocalizations.of(context).translate('deleteCategory'),
      titleColor: switchAppThemeNotifier.currentTheme,
      msgStr:
          AppLocalizations.of(context).translate('confirmDeleteCategoryTodo'),
      positiveBtnStr: cmnOkay,
      negativeBtnStr: AppLocalizations.of(context).translate('cancel'),
    );
  }

  // 単一のCategoryを指定されたFireStore Collectionから削除します。
  void deleteCategory(
    String collection,
    String documentId,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection(collection)
        .doc(documentId)
        .delete();
  }

  void updateCategory(
    String collection,
    String documentId,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection(collection)
        .doc(documentId)
        .update({"name": taskName});
  }

  void deleteCategoryTodoList(
    String categoryId,
  ) {
    try {
      FirebaseFirestore.instance
          .collection('to-dos')
          .where('categoryId', isEqualTo: '$categoryId')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void openModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddCategoryBottomSheet(
          onNameChange: (String text) {
            onNameChange(text);
          },
          onPressed: addCategory,
        );
      },
    );
  }

  void editCategory({
    String collection,
    String documentId,
    String initialValue,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return EditCategoryBottomSheet(
          buttonTitle: 'Update Category',
          initialValue: initialValue,
          onPressed: () {
            Navigator.of(context).pop();
            updateCategory(collection, documentId);
          },
          onNameChange: (String text) {
            onNameChange(text);
          },
        );
      },
    );
  }
}
