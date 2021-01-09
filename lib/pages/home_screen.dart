import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:firebase_sample/pages/home_screen_notifier.dart';
import 'package:firebase_sample/tabs/custom_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen();

  static String routeName = 'home-screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeScreenNotifier(
        context: context,
      ),
      child: _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: switchAppThemeNotifier.currentTheme,
        actions: [
          Icon(Icons.folder_open),
          const SizedBox(width: 20),
          InkWell(
            onTap: notifier.navigateSettingScreen,
            child: Icon(Icons.settings),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: CustomTabView(
        initPosition: 0,
        itemCount: 10,
        tabBuilder: (context, index) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 100,
              maxHeight: 35,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: switchAppThemeNotifier.currentTheme,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Tab(
                text: 'カテゴリー$index',
              ),
            ),
          );
        },
        pageBuilder: (context, index) {
          return ColoredBox(
            color: darkModeNotifier.isLightTheme ? white : darkBlack,
            child: createListView(context),
          );
        },
        onPositionChange: (index) {
//          notifier.setCurrentIndex(index);
//          notifier.initPosition = index;
        },
        onScroll: (position) {},
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: switchAppThemeNotifier.currentTheme,
        onPressed: () async {
          notifier.openModalBottomSheet();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget createListView(BuildContext context) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return StreamBuilder(
      stream: Firestore.instance.collection('to-dos').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError || snapshot.data == null) {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              switchAppThemeNotifier.currentTheme,
            ),
          );
        } else {
          return ListView(
            children: snapshot.data.documents.map(
              (DocumentSnapshot document) {
                if (document == null) {
                  return Container();
                } else {
                  return Card(
                    child: ListTile(
                      dense: true,
                      leading: CircularCheckBox(
                        value: document['isChecked'],
                        checkColor: Colors.white,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.blue,
                        disabledColor: Colors.grey,
                        onChanged: (val) {
                          notifier.updateTodoIsChecked(
                            'to-dos',
                            document.documentID,
                            !document['isChecked'],
                          );
                        },
                      ),
                      title: InkWell(
                        onTap: () {
                          notifier.editTodo(
                            collection: 'to-dos',
                            documentId: document.documentID,
                            initialValue: document['name'],
                          );
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  document['name'] ?? '',
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    decoration: document['isChecked']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 画像部分の表示
                      subtitle: document['imagePath'] != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: InkWell(
                                  onTap: () {
                                    notifier.editTodo(
                                      collection: 'to-dos',
                                      documentId: document.documentID,
                                      initialValue: document['name'],
                                    );
                                  },
                                  child: Image.network(
                                    document['imagePath'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: AspectRatio(
                                            aspectRatio: notifier
                                                .videoController
                                                .value
                                                .aspectRatio,
                                            child: VideoPlayer(
                                              notifier.videoController,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                )
                              : null,
                    ),
                  );
                }
              },
            ).toList(),
          );
        }
      },
    );
  }
}
