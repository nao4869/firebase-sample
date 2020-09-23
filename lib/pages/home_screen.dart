import 'dart:io';

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

  String onValidate(String text) {
    // resultType = validator.validate(text);
    // return resultType.errorMessage(Strings.of(navigator.context));
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
                    subtitle: Image.network(
                      notifier.postList[index].imagePath,
                      fit: BoxFit.cover,
                    ),
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            children: <Widget>[
                              SimpleDialogOption(
                                onPressed: () {
                                  notifier
                                      .deletePost(notifier.postList[index].id);
                                  Navigator.of(context).pop();
                                },
                                child: Center(
                                  child: Text('削除'),
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context),
                                child: Center(
                                  child: Text('編集'),
                                ),
                              ),
                            ],
                          );
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
              return SimpleDialog(
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {},
                    child: Column(
                      children: [
                        CustomTextFormField(
                          formKey: nameFieldFormKey,
                          height: 80,
                          onValidate: onValidate,
                          onChanged: onNameChange,
                          controller: textController,
                          resetTextField: resetNameTextField,
                          hintText: 'タスク名',
                          counterText: '50',
                        ),
                        RaisedButton(
                          color: Colors.blue,
                          elevation: 0,
                          onPressed: () {
                            // ダイアログを閉じます
                            Navigator.of(context).pop();
                            uploadFile();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '投稿する',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
