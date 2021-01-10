import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:firebase_sample/pages/home/home_screen_notifier.dart';
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
          InkWell(
            onTap: notifier.navigateAddCategoryScreen,
            child: Icon(Icons.folder_open),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: notifier.navigateSettingScreen,
            child: Icon(Icons.settings),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('category').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // エラーの場合
            if (snapshot.hasError || snapshot.data == null) {
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  switchAppThemeNotifier.currentTheme,
                ),
              );
            } else {
              return CustomTabView(
                initPosition: notifier.initPosition,
                itemCount: snapshot.data.documents.length,
                tabBuilder: (context, index) {
                  notifier.updateCurrentTabId(
                      snapshot.data.documents[index].documentID);
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
                        text: snapshot.data.documents[index].data['name']
                            .toString(),
                      ),
                    ),
                  );
                },
                pageBuilder: (context, index) {
                  return ColoredBox(
                    color: darkModeNotifier.isLightTheme ? white : darkBlack,
                    child: createListView(
                      context: context,
                      categoryId: snapshot.data.documents[index].documentID,
                    ),
                  );
                },
                onPositionChange: (index) {
                  notifier.setCurrentIndex(index);
                  notifier.initPosition = index;
                  notifier.updateCurrentTabId(
                      snapshot.data.documents[index].documentID);
                },
                onScroll: (position) {},
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: switchAppThemeNotifier.currentTheme,
        onPressed: () async {
          notifier.openModalBottomSheet();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget createListView({
    BuildContext context,
    String categoryId,
  }) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return StreamBuilder(
      stream: Firestore.instance
          .collection('to-dos')
          .where('categoryId', isEqualTo: '$categoryId')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError || snapshot.data == null) {
          return Container();
        } else {
          return ListView(
            children: snapshot.data.documents.map(
              (DocumentSnapshot document) {
                if (document == null) {
                  return Container();
                } else {
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        leading: CircularCheckBox(
                          value: document['isChecked'],
                          checkColor: Colors.white,
                          activeColor: switchAppThemeNotifier.currentTheme,
                          inactiveColor: switchAppThemeNotifier.currentTheme,
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
                        subtitle: document['imagePath'] != null &&
                                document['imagePath'] != ''
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: InkWell(
                                    onTap: () {
                                      notifier.navigateZoomImageScreen(
                                        document['imagePath'],
                                        document.documentID,
                                      );
//                                    notifier.editTodo(
//                                      collection: 'to-dos',
//                                      documentId: document.documentID,
//                                      initialValue: document['name'],
//                                    );
                                    },
                                    child: Hero(
                                      tag: document.documentID,
                                      child: Image.network(
                                        document['imagePath'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : document['videoPath'] != null &&
                                    document['videoPath'] != ''
                                ? FutureBuilder(
                                    future:
                                        notifier.initializeVideoPlayerFuture,
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
                        trailing: InkWell(
                          onTap: () {
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color:
                            darkModeNotifier.getThemeData == lightTheme ? Colors.grey : warmGrey,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 1,
                        indent: 0,
                        thickness: .3,
                      ),
                    ],
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
