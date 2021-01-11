import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/widgets/buttons/full_width_button.dart';
import 'package:firebase_sample/widgets/buttons/raised_button.dart';
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
                deleteCategory(collection, documentId);
                deleteCategoryTodoList(documentId);
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
    Navigator.of(context).pop();
    Firestore.instance.collection('category').add({
      'name': taskName,
    });
    notifyListeners();
  }

  // 単一のCategoryを指定されたFireStore Collectionから削除します。
  void deleteCategory(
    String collection,
    String documentId,
  ) {
    Firestore.instance.collection(collection).document(documentId).delete();
  }

  void updateCategory(
    String collection,
    String documentId,
  ) {
    Firestore.instance
        .collection(collection)
        .document(documentId)
        .updateData({"name": taskName});
  }

  void deleteCategoryTodoList(
    String categoryId,
  ) {
    try {
      Firestore.instance
          .collection('to-dos')
          .where('categoryId', isEqualTo: '$categoryId')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void openModalBottomSheet() {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: size.width * .85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.width * .1,
                  width: size.width * .9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      maxLines: 20,
                      autofocus: true,
                      onChanged: (String text) {
                        onNameChange(text);
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: size.width * .9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CommonRaisedButton(
                        title: AppLocalizations.of(context)
                            .translate('addCategory'),
                        onPressed: addCategory,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void editCategory({
    String collection,
    String documentId,
    String initialValue,
  }) {
    final size = MediaQuery.of(context).size;
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: size.width * .2,
                  width: size.width * .9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      maxLines: 20,
                      autofocus: true,
                      onChanged: (String text) {
                        onNameChange(text);
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: size.width,
                child: FullWidthButton(
                  title: 'Update Category',
                  onPressed: () {
                    Navigator.of(context).pop();
                    updateCategory(collection, documentId);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
