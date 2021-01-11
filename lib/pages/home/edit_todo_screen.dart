import 'dart:io';

import 'package:firebase_sample/models/provider/post_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_sample/models/post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditTodoScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  final Post editingTodo;

  const EditTodoScreen({
    this.editingTodo,
  });

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            widget.editingTodo.name,
          ),
          widget.editingTodo.imagePath != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.network(
                    widget.editingTodo.imagePath,
                    fit: BoxFit.cover,
                  ),
                )
              : const SizedBox()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
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
