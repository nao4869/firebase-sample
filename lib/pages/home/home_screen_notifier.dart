import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/pages/home/zoom_tweet_image_screen.dart';
import 'package:firebase_sample/pages/settings/settings_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/date_picker_bottom_sheet.dart';
import 'package:firebase_sample/widgets/bottom_sheet/edit_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/bottom_sheet_content/date_row.dart';
import 'package:firebase_sample/widgets/bottom_sheet_content/input_field.dart';
import 'package:firebase_sample/widgets/buttons/full_width_button.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_sample/extensions/set_image_path.dart';

import '../../app_localizations.dart';

class HomeScreenNotifier extends ChangeNotifier {
  HomeScreenNotifier({
    this.context,
  }) {
    textController.text = '';
    videoController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    initializeVideoPlayerFuture = videoController.initialize();
  }
  final BuildContext context;
  var isLoading = false;
  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  String taskName;
  bool isValid = false;

  File _image;
  String _uploadedFileURL;

  String createdDate;
  bool get isDateValid => createdDate != null;

  VideoPlayerController videoController;
  Future<void> initializeVideoPlayerFuture;
  String currentTabDocumentId = '';
  int currentTabIndex = 0;
  int initPosition = 0;
  bool isInitialLoadCompleted = false;

  int _selectedPersonIndex;

  @override
  void dispose() {
    textController.dispose();
    videoController.dispose();
    super.dispose();
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

  void createPostWithoutImage() {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    Navigator.of(context).pop();
    // GroupのサブコレクションのサブコレクションCategory下にTo-dosを作成
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(currentTabDocumentId)
        .collection('to-dos')
        .add({
      'name': taskName,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'imagePath': null,
      'videoPath': null,
      'isChecked': false,
    });
  }

  void updateTodoIsChecked(
    String collection,
    String documentId,
    bool isChecked,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(currentTabDocumentId)
        .collection(collection)
        .doc(documentId)
        .update({"isChecked": isChecked});
  }

  void updateTodoName(
    String collection,
    String documentId,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(currentTabDocumentId)
        .collection(collection)
        .doc(documentId)
        .update({"name": taskName});
  }

  // 単一のTodoを指定されたFireStore Collectionから削除します。
  void deleteTodo(
    String collection,
    String documentId,
  ) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupNotifier.groupId)
        .collection('categories')
        .doc(currentTabDocumentId)
        .collection(collection)
        .doc(documentId)
        .delete();
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    taskName = text;
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    taskName = '';
    notifyListeners();
  }

  void playAndPauseVideo() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }
    notifyListeners();
  }

  /// 画像ファイルをストレージにアップロードする関数です
  Future uploadFile() async {
    _image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 800,
    );

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image.path)}}');
    await storageReference.putFile(_image);

    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
      FirebaseFirestore.instance.collection('to-dos').add({
        'name': taskName,
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
      final file = await ImagePicker.pickVideo(source: ImageSource.gallery);

      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('videos/${Path.basename(file.path)}}');

      await storageReference.putFile(
          file, firebase_storage.SettableMetadata(contentType: 'video/mp4'));

      storageReference.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;

        FirebaseFirestore.instance.collection('to-dos').add({
          'name': taskName,
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

  void showModalPicker() {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: size.height * .65,
          child: DatePickerBottomSheet(
            initialDateString: '',
            isValid: isDateValid,
            onPressedNext: null,
            onPressedDone: () {
              Navigator.of(context).pop();
            },
            onDateTimeChanged: _onSelectedItemChanged,
          ),
        );
      },
    );
  }

  void _onSelectedItemChanged(String value) {
    createdDate = value;
    notifyListeners();
  }

  void openModalBottomSheet() {
    final size = MediaQuery.of(context).size;
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final switchAppThemeNotifier =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InputField(
                    onChanged: (String text) {
                      onNameChange(text);
                    },
                  ),
                  DateRow(
                    createdDate: createdDate,
                    onPressed: showModalPicker,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
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
                          height: 40,
                          width: size.width * .9,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              Text(
                                'Who\'s task?',
                                style: TextStyle(
                                  fontSize: 15.0,
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
                                itemBuilder: (BuildContext context, int index) {
                                  final imageWidget = setImagePath(snapshot
                                      .data.docs[index]
                                      .data()['imagePath']);
                                  return InkWell(
                                    onTap: () {
                                      _selectedPersonIndex = index;
                                      setState(() {});
                                    },
                                    child: SizedBox(
                                      height: 30,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Stack(
                                          children: [
                                            imageWidget,
                                            if (_selectedPersonIndex == index)
                                              SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color:
                                                        switchAppThemeNotifier
                                                            .currentTheme
                                                            .withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
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
                      title: AppLocalizations.of(context).translate('post'),
                      onPressed: createPostWithoutImage,
                    ),
                  ),
                ],
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
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EditCategoryBottomSheet(
          buttonTitle: 'Update Todo',
          collection: collection,
          documentId: documentId,
          initialValue: initialValue,
          onPressed: () {
            Navigator.of(context).pop();
            updateTodoName(collection, documentId);
          },
          onNameChange: (String text) {
            onNameChange(text);
          },
        );
      },
    );
  }
}
