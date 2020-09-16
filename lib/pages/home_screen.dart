import 'dart:io';

import 'package:firebase_sample/Utility/utility.dart';
import 'package:firebase_sample/models/post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              //dense: true,
              leading: Text(
                'dogsNotifier.dogsList[index].id.toString()',
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'dogsNotifier.dogsList[index].name',
                      ),
                      Text(
                        'dogsNotifier.dogsList[index].age.toString()' + '歳',
                      ),
                    ],
                  ),
                  Text(
                    'dogsNotifier.dogsList[index].createdAt',
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
                          onPressed: () {},
                          child: Center(child: Text('削除')),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context),
                          child: Center(child: Text('編集')),
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
          final time = DateTime.now().millisecondsSinceEpoch;
          var imageFile;
          var imageString;
          final picker = ImagePicker();
          final pickedFile = await picker.getImage(
            source: ImageSource.gallery,
            maxHeight: 600,
            maxWidth: 800,
          );
          if (pickedFile == null) return;
          imageFile = File(pickedFile.path);

          if (imageFile != null) {
            final Directory directory =
                await getApplicationDocumentsDirectory();
            final String path = directory.path;
            final File newImage = await imageFile.copy('$path/$time.png');

            setState(() {
              imageFile = newImage;
            });

            imageString = Utility.base64String(imageFile.readAsBytesSync());
          }

          final post = Post(
            id: time.toString(),
            name: 'Todo',
            imagePath: imageString,
            createdAt: DateTime.now().toIso8601String(),
          );

          // データベースへ保存 - 挿入
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
