import 'package:firebase_sample/models/post.dart';
import 'package:firebase_sample/models/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isLoading = false;
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
    super.initState();
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    final notifier = Provider.of<PostProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? _buildProgressIndicator()
          : ListView.builder(
              shrinkWrap: true,
              itemCount: notifier.postsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    //dense: true,
                    leading: Text(
                      notifier.postsList[index].id.toString(),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              notifier.postsList[index].name,
                            ),
                          ],
                        ),
                        Text(
                          notifier.postsList[index].createdAt,
                        ),
                      ],
                    ),
                    // subtitle: SizedBox(
                    //   width: size.width * .8,
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(10.0),
                    //     child: Utility.imageFromBase64String(
                    //       '',
                    //     ),
                    //   ),
                    // ),
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
                                      .deletePost(notifier.postsList[index].id);
                                  Navigator.of(context).pop();
                                },
                                child: Center(child: Text('削除')),
                              ),
//                              SimpleDialogOption(
//                                onPressed: () => Navigator.pop(context),
//                                child: Center(child: Text('編集')),
//                              ),
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
          print(notifier.postsList.length.toString());
          final post = Post(
            id: notifier.postsList.length.toString(),
            name: 'Todo',
            imagePath: null,
            createdAt: DateTime.now().toIso8601String(),
          );

          // データベースへ保存 - 挿入
          notifier.addPost(post);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//          var imageFile;
//          var imageString;
//          final picker = ImagePicker();
//          final pickedFile = await picker.getImage(
//            source: ImageSource.gallery,
//            maxHeight: 600,
//            maxWidth: 800,
//          );
//          if (pickedFile == null) return;
//          imageFile = File(pickedFile.path);
//
//          if (imageFile != null) {
//            final Directory directory =
//                await getApplicationDocumentsDirectory();
//            final String path = directory.path;
//            final File newImage = await imageFile.copy('$path/$time.png');
//
//            setState(() {
//              imageFile = newImage;
//            });
//
//            imageString = Utility.base64String(imageFile.readAsBytesSync());
//          }
