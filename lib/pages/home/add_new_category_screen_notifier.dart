import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/add_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/bottom_sheet/edit_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class AddCategoryScreenNotifier extends ChangeNotifier {
  AddCategoryScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.parentCategoryIdNotifier,
    this.userNotifier,
  }) {
    /// Controllerを初期化
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    screenSize = ScreenSize(
        size: MediaQuery.of(context).size,
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    sizeType = screenSize.specifyScreenSizeType();
    currentTabDocumentId = parentCategoryIdNotifier.currentParentCategoryId;
    print(currentTabDocumentId);
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final CurrentParentCategoryIdProvider parentCategoryIdNotifier;
  final UserReferenceProvider userNotifier;

  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  ScreenSize screenSize;
  ScreenSizeType sizeType;

  SlidableController slidableController;
  String taskName;
  int selectedColorIndex = 0;
  bool isValid = false;

  Animation<double> rotationAnimation;
  Color fabColor = Colors.blue;

  String currentTabDocumentId = '';
  int currentTabIndex = 0;
  int initPosition = 0;
  bool isInitialLoadCompleted = false;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    rotationAnimation = slideAnimation;
    notifyListeners();
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    fabColor = isOpen ? Colors.green : Colors.blue;
    notifyListeners();
  }

  void setInitialTabId(String categoryId) {
    if (!isInitialLoadCompleted) {
      currentTabDocumentId = categoryId;
    } else {
      return;
    }
    isInitialLoadCompleted = true;
  }

  void updateFirestoreParentCategoryId() {
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
        .update({"currentParentCategoryId": currentTabDocumentId});

    // User Providerの値も更新
    userNotifier.updateParentCategoryReference(currentTabDocumentId);
    parentCategoryIdNotifier
        .updateCurrentParentCategoryId(currentTabDocumentId);
  }

  void updateCurrentTabId(String categoryId) {
    currentTabDocumentId = categoryId;
    parentCategoryIdNotifier.updateCurrentParentCategoryId(categoryId);
  }

  void pop() {
    updateFirestoreParentCategoryId();
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
    SlideActionType actionType,
    String collection,
    String documentId,
    String initialValue,
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
                  initialValue: initialValue,
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
                  actionType,
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

  /// 親カテゴリーを追加する関数
  void addParentCategory() {
    if (taskName != null && taskName != '') {
      final groupNotifier =
          Provider.of<CurrentGroupProvider>(context, listen: false);
      Navigator.of(context).pop();
      FirebaseFirestore.instance
          .collection('versions')
          .doc('v2')
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
  }

  /// 子カテゴリーを追加する関数
  /// colorのみ指定し、タスク名を追加は行わない
  void addCategory() {
    if (taskName != null && taskName != '') {
      final groupNotifier =
          Provider.of<CurrentGroupProvider>(context, listen: false);
      Navigator.of(context).pop();
      FirebaseFirestore.instance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('categories')
          .doc(parentCategoryIdNotifier.currentParentCategoryId)
          .collection('children')
          .add({
        // Groupのサブコレクションに、Categoryを作成
        'name': taskName,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      notifyListeners();
    }
  }

  Widget deleteConfirmDialog(
    SlideActionType actionType,
    String collection,
    String documentId,
  ) {
    return CmnDialog(context).showDialogWidget(
      onPositiveCallback: () {
        deleteCategory(
          collection,
          documentId,
        );
        deleteCategoryTodoList(documentId);
        showSnackBar(
          context,
          actionType == SlideActionType.primary
              ? 'Dismiss Archive'
              : AppLocalizations.of(context).translate('todoDeleted'),
        );
      },
      onNegativeCallback: () {},
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
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(parentCategoryIdNotifier.currentParentCategoryId)
        .collection('children')
        .doc(documentId)
        .delete();
  }

  void updateCategory(
    String collection,
    String documentId,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final parentIdNotifier =
        Provider.of<CurrentParentCategoryIdProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(parentIdNotifier.currentParentCategoryId)
        .collection('children')
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

  void openModalBottomSheet(bool isParentCategory) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        if (isParentCategory) {
          return AddCategoryBottomSheet(
            onNameChange: (String text) {
              onNameChange(text);
            },
            title: AppLocalizations.of(context).translate('addParentCategory'),
            onPressed: addParentCategory,
          );
        } else {
          return AddCategoryBottomSheet(
            onNameChange: (String text) {
              onNameChange(text);
            },
            title: AppLocalizations.of(context).translate('addCategory'),
            onPressed: addCategory,
          );
        }
      },
    );
  }

  void editCategory({
    String collection,
    String documentId,
    String initialValue,
  }) {
    taskName = initialValue;
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
          buttonTitle: AppLocalizations.of(context).translate('updateCategory'),
          initialValue: initialValue,
          isDisplayLowerField: false,
          onUpdatePressed: () {
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

  static Widget getActionPane(int index) {
    switch (index % 4) {
      case 0:
        return SlidableBehindActionPane();
      case 1:
        return SlidableStrechActionPane();
      case 2:
        return SlidableScrollActionPane();
      case 3:
        return SlidableDrawerActionPane();
      default:
        return null;
    }
  }

  static Color getAvatarColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.indigoAccent;
      default:
        return null;
    }
  }

  static String getSubtitle(int index) {
    switch (index % 4) {
      case 0:
        return 'SlidableBehindActionPane';
      case 1:
        return 'SlidableStrechActionPane';
      case 2:
        return 'SlidableScrollActionPane';
      case 3:
        return 'SlidableDrawerActionPane';
      default:
        return null;
    }
  }

  void showSnackBar(
    BuildContext context,
    String text,
  ) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
