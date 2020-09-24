import 'dart:io';

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

  Future uploadFile() async {
    final notifier = Provider.of<PostProvider>(context, listen: false);
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

      /// 保存するPostインスタンスを作成
      final photo = Post(
        id: notifier.postList.length.toString(),
        name: taskName,
        createdAt: DateTime.now().toIso8601String(),
        imagePath: _uploadedFileURL,
      );
      notifier.addPost(photo);
    });
  }

  void createPostWithoutImage() {
    final notifier = Provider.of<PostProvider>(context, listen: false);

    /// 保存するPostインスタンスを作成
    final photo = Post(
      id: notifier.postList.length.toString(),
      name: taskName,
      createdAt: DateTime.now().toIso8601String(),
      imagePath: null,
    );
    notifier.addPost(photo);
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    taskName = text;
    setState(() {});
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    taskName = '';
    setState(() {});
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<PostProvider>(context, listen: false)
          .retrievePostData()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
    textController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
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
      body: _isLoading
          ? _buildProgressIndicator()
          : ListView.builder(
              shrinkWrap: true,
              itemCount: notifier.postList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              notifier.postList[index].name,
                            ),
                          ],
                        ),
                        Text(
                          notifier.postList[index].createdAt,
                        ),
                      ],
                    ),
                    // 画像部分の表示
                    subtitle: notifier.postList[index].imagePath != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              notifier.postList[index].imagePath,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(),
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return _buildDialogOptions(index);
                        },
                      );
                    },
                  ),
                );
              },
            ),
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
}
