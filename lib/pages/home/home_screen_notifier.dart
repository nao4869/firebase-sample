import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen.dart';
import 'package:firebase_sample/pages/home/zoom_tweet_image_screen.dart';
import 'package:firebase_sample/pages/settings/settings_screen.dart';
import 'package:firebase_sample/widgets/bottom_sheet/date_picker_bottom_sheet.dart';
import 'package:firebase_sample/widgets/bottom_sheet/edit_category_bottom_sheet.dart';
import 'package:firebase_sample/widgets/buttons/full_width_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as Path;

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
    Navigator.of(context).pop();
    Firestore.instance.collection('to-dos').add({
      'name': taskName,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'imagePath': null,
      'videoPath': null,
      'isChecked': false,
      'categoryId': currentTabDocumentId,
    });
  }

  void updateTodoIsChecked(
    String collection,
    String documentId,
    bool isChecked,
  ) {
    Firestore.instance
        .collection(collection)
        .document(documentId)
        .updateData({"isChecked": isChecked});
  }

  void updateTodoName(
    String collection,
    String documentId,
  ) {
    Firestore.instance
        .collection(collection)
        .document(documentId)
        .updateData({"name": taskName});
  }

  // 単一のTodoを指定されたFireStore Collectionから削除します。
  void deleteTodo(
    String collection,
    String documentId,
  ) {
    Firestore.instance.collection(collection).document(documentId).delete();
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

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
      Firestore.instance.collection('to-dos').add({
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

      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('videos/${Path.basename(file.path)}}');

      StorageUploadTask uploadTask = storageReference.putFile(
          file, StorageMetadata(contentType: 'video/mp4'));
      await uploadTask.onComplete;

      storageReference.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;

        Firestore.instance.collection('to-dos').add({
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: size.width * .3,
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
              InkWell(
                onTap: showModalPicker,
                child: SizedBox(
                  height: 40,
                  width: size.width * .9,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        'When?',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        createdDate != null
                            ? createdDate.substring(0, 10)
                            : 'No remind date',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: switchAppThemeNotifier.currentTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
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
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: 10);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {},
                          child: SizedBox(
                            height: 30,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/default_profile_image.png',
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: 3,
                    ),
                  ],
                ),
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
