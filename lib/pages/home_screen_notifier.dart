import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as Path;

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

  VideoPlayerController videoController;
  Future<void> initializeVideoPlayerFuture;

  @override
  void dispose() {
    textController.dispose();
    videoController.dispose();
    super.dispose();
  }

  void popDialog() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  void createPostWithoutImage() {
    Firestore.instance.collection('posts').add({
      'name': taskName,
      'createdAt': DateTime.now().toIso8601String(),
      'imagePath': null,
      'videoPath': null,
    });
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
      Firestore.instance.collection('posts').add({
        'name': taskName,
        'createdAt': DateTime.now().toIso8601String(),
        'imagePath': _uploadedFileURL,
        'videoPath': null,
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

        Firestore.instance.collection('posts').add({
          'name': taskName,
          'createdAt': DateTime.now().toIso8601String(),
          'imagePath': null,
          'videoPath': _uploadedFileURL,
        });
      });
    } catch (error) {
      print(error);
    }
  }
}
