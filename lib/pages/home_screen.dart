import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/pages/edit_todo_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_sample/models/post.dart';
import 'package:firebase_sample/models/post_provider.dart';
import 'package:firebase_sample/widgets/text_form_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isLoading = false;

  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  String taskName;
  bool isValid = false;

  File _image;
  String _uploadedFileURL;

  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;

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
    setState(() {});
  }

  @override
  void initState() {
    textController.text = '';

    _videoController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );

    _initializeVideoPlayerFuture = _videoController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PostProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading ? _buildProgressIndicator() : createListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return _buildAddTaskDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 削除、編集などのダイアログの項目を表示します
  /// @param index : postListの該当index
  Widget _buildDialogOptions(
    int index,
  ) {
    final notifier = Provider.of<PostProvider>(context);
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            notifier.deletePost(notifier.postList[index].id);
            Navigator.of(context).pop();
          },
          child: Center(
            child: Text('削除'),
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            // 編集時のProviderの処理
            Navigator.of(context).pop();
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (context) => EditTodoScreen(
                  editingTodo: notifier.postList[index],
                ),
              ),
            );
          },
          child: Center(
            child: Text('編集'),
          ),
        ),
      ],
    );
  }

  /// TODOタスク追加時の表示ダイアログ
  Widget _buildAddTaskDialog() {
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: Column(
            children: [
              CustomTextFormField(
                formKey: nameFieldFormKey,
                height: 80,
                onChanged: onNameChange,
                controller: textController,
                resetTextField: resetNameTextField,
                hintText: 'タスク名',
                counterText: '50',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildRaisedButton(
                    title: '画像を追加する',
                    onPressed: () {
                      // ダイアログを閉じます
                      Navigator.of(context).pop();
                      uploadFile();
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildRaisedButton(
                    title: '投稿する',
                    onPressed: () {
                      // ダイアログを閉じます
                      Navigator.of(context).pop();
                      createPostWithoutImage();
                    },
                  ),
                ],
              ),
              _buildRaisedButton(
                title: '動画を追加する',
                onPressed: () {
                  // ダイアログを閉じます
                  Navigator.of(context).pop();
                  uploadVideoToStorage();
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRaisedButton({
    @required String title,
    @required VoidCallback onPressed,
  }) {
    return RaisedButton(
      color: Colors.blue,
      elevation: 0,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget createListView() {
    Firestore.instance.collection('posts').snapshots().listen((data) {
      print(data);
    });

    return StreamBuilder(
      stream: Firestore.instance.collection('posts').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // 通信中の場合
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading ...');
          default:
            return ListView(
              children: snapshot.data.documents.map(
                (DocumentSnapshot document) {
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'タスク詳細: ' + document['name'],
                                  maxLines: 10,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '作成日: ' + document['createdAt'].toString(),
                          ),
                        ],
                      ),
                      // 画像部分の表示
                      subtitle: document['imagePath'] != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.network(
                                document['imagePath'],
                                fit: BoxFit.cover,
                              ),
                            )
                          : document['videoPath'] != null
                              ? FutureBuilder(
                                  future: _initializeVideoPlayerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            // If the video is playing, pause it.
                                            if (_videoController
                                                .value.isPlaying) {
                                              _videoController.pause();
                                            } else {
                                              // If the video is paused, play it.
                                              _videoController.play();
                                            }
                                          });
                                        },
                                        child: AspectRatio(
                                          aspectRatio: _videoController
                                              .value.aspectRatio,
                                          child: VideoPlayer(_videoController),
                                        ),
                                      );
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                )
                              : const SizedBox(),
                      trailing: Icon(Icons.more_vert),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return _buildDialogOptions(0);
                          },
                        );
                      },
                    ),
                  );
                },
              ).toList(),
            );
        }
      },
    );
  }
}
