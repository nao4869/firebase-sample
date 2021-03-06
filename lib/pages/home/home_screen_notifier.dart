import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/pages/home/edit_group_name_screen.dart';
import 'package:firebase_sample/pages/home/zoom_tweet_image_screen.dart';
import 'package:firebase_sample/pages/settings/settings_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/edit_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/bottom_sheet_content/date_row.dart';
import 'package:firebase_sample/widgets/bottom_sheet_content/input_field.dart';
import 'package:firebase_sample/widgets/buttons/full_width_button.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_sample/extensions/set_image_path.dart';

import '../../app_localizations.dart';

class HomeScreenNotifier extends ChangeNotifier {
  HomeScreenNotifier({
    this.context,
    this.parentCategoryIdNotifier,
  }) {
    textController.text = '';
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    screenSize = ScreenSize(
        size: MediaQuery.of(context).size,
        pixelRatio: MediaQuery.of(context).devicePixelRatio);
    sizeType = screenSize.specifyScreenSizeType();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: AppLocalizations.of(context).translate('doReview'),
          message: AppLocalizations.of(context).translate('ifYouLikeApp'),
          rateButton: AppLocalizations.of(context).translate('doReview'),
          noButton: AppLocalizations.of(context).translate('notNow'),
          laterButton: AppLocalizations.of(context).translate('later'),
          listener: (button) {
            // The button click listener (useful if you want to cancel the click event).
            switch (button) {
              case RateMyAppDialogButton.rate:
                rateMyApp.launchStore();
                break;
              case RateMyAppDialogButton.later:
                debugPrint('Clicked on "Later".');
                break;
              case RateMyAppDialogButton.no:
                debugPrint('Clicked on "No".');
                break;
            }
            return true; // Return false if you want to cancel the click event.
          },
        );
      }
    });
  }

  final BuildContext context;
  final CurrentParentCategoryIdProvider parentCategoryIdNotifier;
  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  ScreenSize screenSize;
  ScreenSizeType sizeType;

  String _taskName;
  bool isValid = false;

  File _image;
  String _uploadedFileURL;
  int _selectedPersonIndex;

  DateTime _selectedRemindDate;
  bool get isDateValid => _selectedRemindDate != null;

  SlidableController slidableController;
  String currentTabDocumentId = '';
  int currentTabIndex = 0;
  int initPosition = 0;
  bool isInitialLoadCompleted = false;
  String _referenceToUser = '';
  String _selectedPersonId = '';
  List<QueryDocumentSnapshot> todoList = [];

  Animation<double> rotationAnimation;
  Color fabColor = Colors.blue;

  /// 評価ポップアップ表示用のライブラリインスタンス
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_ShareDo',
    minDays: 0, // 0の際には、初日でも表示可能
    minLaunches: 2, // minDaysを経過し、最低起動回数を超えた際に表示
    remindDays: 1, // 再表示時までの、起動最低日数
    remindLaunches: 2, // 再表示時までの、起動回数
    appStoreIdentifier: '1553758427',
    googlePlayIdentifier: 'com.share.todo.list',
  );

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    notifyListeners();
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    notifyListeners();
    refreshController.loadComplete();
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    rotationAnimation = slideAnimation;
    notifyListeners();
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    fabColor = isOpen ? Colors.green : Colors.blue;
    notifyListeners();
  }

  // 完了済みタスク表示、非表示切り替え
  void updateTodoList(
    List<QueryDocumentSnapshot> snapshot,
  ) {
    final userNotifier =
        Provider.of<UserReferenceProvider>(context, listen: false);
    if (userNotifier.isDisplayCompletedTodo) {
      todoList = snapshot;
    } else if (userNotifier.isDisplayOnlyCompletedTodo) {
      todoList =
          snapshot.where((element) => element['isChecked'] == true).toList();
    } else {
      todoList =
          snapshot.where((element) => element['isChecked'] == false).toList();
    }
  }

  void setCurrentIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void navigateSettingScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  void navigateAddCategoryScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => AddCategoryScreen(),
      ),
    );
  }

  void navigateEditGroupNameScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditGroupNameScreen(),
      ),
    );
  }

  void navigateZoomImageScreen(
    String imagePath,
    String heroTag,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => ZoomImageScreen(
          imagePath: imagePath,
          heroTagName: heroTag,
        ),
      ),
    );
  }

  void setInitialTabId(String categoryId) {
    if (!isInitialLoadCompleted) {
      currentTabDocumentId = categoryId;
    } else {
      return;
    }
    isInitialLoadCompleted = true;
  }

  void updateCurrentTabId(String categoryId) {
    currentTabDocumentId = categoryId;
  }

  Future<void> createPostWithoutImage() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    Navigator.of(context).pop();

    // タスク担当ユーザーの参照を取得
    DocumentSnapshot userReference;
    if (_referenceToUser != null && _referenceToUser.isNotEmpty) {
      userReference = await FirebaseFirestore.instance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .doc(_referenceToUser)
          .get();
    }

    // TODO: remindDateを入力できるようにする
    // GroupのサブコレクションのサブコレクションCategory下にTo-dosを作成
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(parentCategoryIdNotifier.currentParentCategoryId)
        .collection('children')
        .doc(currentTabDocumentId)
        .collection('to-dos')
        .add({
      'name': _taskName,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'remindDate': _selectedRemindDate != null
          ? Timestamp.fromDate(_selectedRemindDate)
          : null,
      'imagePath': null,
      'videoPath': null,
      'isChecked': false,
      'taggedUserReference':
          userReference != null ? userReference.reference : null,
    });
    _selectedRemindDate = null;
    _selectedPersonIndex = null;
    _taskName = '';
  }

  void updateTodoIsChecked(
    String collection,
    String documentId,
    bool isChecked,
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
        .doc(currentTabDocumentId)
        .collection(collection)
        .doc(documentId)
        .update({"isChecked": isChecked});
  }

  void updateTodo(
    String collection,
    String documentId,
  ) async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    // 選択中ユーザーIDから、タスク担当ユーザーの参照を取得
    DocumentSnapshot userReference;
    if (_selectedPersonId != null && _selectedPersonId.isNotEmpty) {
      userReference = await FirebaseFirestore.instance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .doc(_selectedPersonId)
          .get();
    }
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v2')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(parentCategoryIdNotifier.currentParentCategoryId)
        .collection('children')
        .doc(currentTabDocumentId)
        .collection(collection)
        .doc(documentId)
        .update({
      "name": _taskName,
      "taggedUserReference":
          userReference != null ? userReference.reference : null,
      'remindDate': _selectedRemindDate != null
          ? Timestamp.fromDate(_selectedRemindDate)
          : null,
    });
  }

  // 単一のTodoを指定されたFireStore Collectionから削除します。
  void deleteTodo(
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
        .doc(currentTabDocumentId)
        .collection(collection)
        .doc(documentId)
        .delete();
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    _taskName = text;
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    _taskName = '';
    notifyListeners();
  }

  /// 画像ファイルをストレージにアップロードする関数です
  Future uploadFile() async {
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 800,
    );
    _image = File(pickedFile.path);

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image.path)}}');
    await storageReference.putFile(_image);

    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
      FirebaseFirestore.instance.collection('to-dos').add({
        'name': _taskName,
        'createdAt': DateTime.now().toIso8601String(),
        'imagePath': _uploadedFileURL,
        'videoPath': null,
        'isChecked': false,
        'categoryId': currentTabDocumentId,
      });
    });
  }

  /// 動画ファイルをストレージにアップロードする関数です
  Future uploadVideoToStorage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getVideo(source: ImageSource.gallery);
      final video = File(pickedFile.path);

      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('videos/${Path.basename(video.path)}}');

      await storageReference.putFile(
          video, firebase_storage.SettableMetadata(contentType: 'video/mp4'));

      storageReference.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;

        FirebaseFirestore.instance.collection('to-dos').add({
          'name': _taskName,
          'createdAt': DateTime.now().toIso8601String(),
          'imagePath': null,
          'videoPath': _uploadedFileURL,
          'isChecked': false,
          'categoryId': currentTabDocumentId,
        });
      });
    } catch (error) {
      print(error);
    }
  }

  void showDateTimePicker() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      currentTime: DateTime.now(),
      minTime: DateTime(2020, 5, 5, 20, 50),
      maxTime: DateTime(2020, 6, 7, 05, 09),
      onChanged: (date) {
        debugPrint('change $date in time zone ' +
            date.timeZoneOffset.inHours.toString());
      },
      onConfirm: (date) {
        _selectedRemindDate = date;
        notifyListeners();
      },
    );
  }

  double setFormHeightByDevice(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (sizeType == ScreenSizeType.xlarge) {
      return size.width * .4;
    } else if (sizeType == ScreenSizeType.xxlarge) {
      return size.width * .4;
    } else {
      return size.width * .3;
    }
  }

  void resetSelectedDate() {
    _selectedRemindDate = null;
    notifyListeners();
  }

  // 新規Todo作成時 ボトムシート表示関数
  void openModalBottomSheet() {
    final size = MediaQuery.of(context).size;
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final switchAppThemeNotifier =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final formHeightByDevice = setFormHeightByDevice(context);
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputField(
                      onChanged: (String text) {
                        onNameChange(text);
                        setState(() {});
                      },
                      height: formHeightByDevice,
                    ),
                    DateRow(
                      remindDate: _selectedRemindDate,
                      onPressed: showDateTimePicker,
                      onReset: resetSelectedDate,
                      sizeType: sizeType,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('versions')
                          .doc('v2')
                          .collection('groups')
                          .doc(groupNotifier.groupId)
                          .collection('users')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        // エラーの場合
                        if (snapshot.hasError || snapshot.data == null) {
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              switchAppThemeNotifier.currentTheme,
                            ),
                          );
                        } else {
                          return SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('whoTask'),
                                  style: TextStyle(
                                    fontSize: sizeType == ScreenSizeType.large
                                        ? 12.0
                                        : 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ListView.separated(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const SizedBox(width: 10);
                                  },
                                  itemCount: snapshot.data.size,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final imageWidget = setImagePath(snapshot
                                        .data.docs[index]
                                        .data()['imagePath']);
                                    return InkWell(
                                      onTap: () {
                                        // 既に選択中のユーザーを再度タップした際に、フォーカスを解除
                                        if (_selectedPersonIndex == index ||
                                            _referenceToUser ==
                                                snapshot.data.docs[index].id) {
                                          _selectedPersonIndex = null;
                                          _referenceToUser = null;
                                        } else {
                                          _selectedPersonIndex = index;
                                          _referenceToUser =
                                              snapshot.data.docs[index].id;
                                        }
                                        setState(() {});
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: imageWidget,
                                                  ),
                                                  if (_selectedPersonIndex ==
                                                      index)
                                                    SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child: DecoratedBox(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          color:
                                                              switchAppThemeNotifier
                                                                  .currentTheme
                                                                  .withOpacity(
                                                                      0.5),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            snapshot.data.docs[index]
                                                        .data()['name']
                                                        .toString()
                                                        .length >
                                                    3
                                                ? snapshot.data.docs[index]
                                                    .data()['name']
                                                    .toString()
                                                    .substring(0, 4)
                                                : snapshot.data.docs[index]
                                                    .data()['name'],
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: size.width,
                      child: FullWidthButton(
                        title: _taskName == null || _taskName == ''
                            ? AppLocalizations.of(context).translate('close')
                            : AppLocalizations.of(context).translate('post'),
                        onPressed: () {
                          if (_taskName == null || _taskName == '') {
                            Navigator.of(context).pop();
                          } else {
                            createPostWithoutImage();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void editTodo({
    String collection,
    String documentId,
    String initialValue,
    String selectedPersonId,
    DateTime remindDate,
  }) {
    _selectedPersonId = selectedPersonId;
    _selectedRemindDate = remindDate;
    // 編集時に初期値を追加
    _taskName = initialValue;
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
        return EditCategoryBottomSheet(
          buttonTitle: AppLocalizations.of(context).translate('updateTodo'),
          initialValue: initialValue,
          selectedRemindDate: _selectedRemindDate,
          selectedPersonId: _selectedPersonId,
          showDateTimePicker: showDateTimePicker,
          onUpdatePressed: () {
            Navigator.of(context).pop();
            updateTodo(collection, documentId);
          },
          onSelectedPersonChanged: (String id) {
            // 同一ユーザータップ時は、フォーカスを削除
            if (_selectedPersonId == id) {
              _selectedPersonId = null;
            } else {
              _selectedPersonId = id;
            }
          },
          onNameChange: (String text) {
            onNameChange(text);
          },
          sizeType: sizeType,
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
