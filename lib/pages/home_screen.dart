import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/pages/home_screen_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_sample/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen();

  static String routeName = 'home-screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeScreenNotifier(),
      child: _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    return Scaffold(
      appBar: AppBar(),
      body: createListView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return _buildAddTaskDialog(context);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 削除、編集などのダイアログの項目を表示します
  /// @param index : postListの該当index
  Widget _buildDialogOptions({
    BuildContext context,
    String collection,
    String documentId,
  }) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop();
            notifier.deleteTodo(collection, documentId);
          },
          child: Center(
            child: Text('削除'),
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            // 編集時のProviderの処理
            //Navigator.of(context).pop();
//            Navigator.of(context, rootNavigator: true).push(
//              CupertinoPageRoute(
//                builder: (context) => EditTodoScreen(
//                  editingTodo: notifier.postList[index],
//                ),
//              ),
//            );
          },
          child: Center(
            child: Text('編集'),
          ),
        ),
      ],
    );
  }

  /// TODOタスク追加時の表示ダイアログ
  Widget _buildAddTaskDialog(BuildContext context) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: Column(
            children: [
              CustomTextFormField(
                formKey: notifier.nameFieldFormKey,
                height: 80,
                onChanged: notifier.onNameChange,
                controller: notifier.textController,
                resetTextField: notifier.resetNameTextField,
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
                      notifier.uploadFile();
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildRaisedButton(
                    title: '投稿する',
                    onPressed: () {
                      // ダイアログを閉じます
                      Navigator.of(context).pop();
                      notifier.createPostWithoutImage();
                    },
                  ),
                ],
              ),
              _buildRaisedButton(
                title: '動画を追加する',
                onPressed: () {
                  // ダイアログを閉じます
                  Navigator.of(context).pop();
                  notifier.uploadVideoToStorage();
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

  Widget createListView(BuildContext context) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
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
                      leading: CircularCheckBox(
                        value: false,
                        checkColor: Colors.white,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.blue,
                        disabledColor: Colors.grey,
                        onChanged: (val) {},
                      ),
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
                            '作成日: ' +
                                document['createdAt']
                                    .toString()
                                    .substring(0, 10),
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
                                  future: notifier.initializeVideoPlayerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return InkWell(
                                        onTap: notifier.playAndPauseVideo,
                                        child: AspectRatio(
                                          aspectRatio: notifier.videoController
                                              .value.aspectRatio,
                                          child: VideoPlayer(
                                              notifier.videoController),
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
                            return _buildDialogOptions(
                              context: context,
                              collection: 'posts',
                              documentId: document.documentID,
                            );
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
