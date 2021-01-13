import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/home/home_screen_notifier.dart';
import 'package:firebase_sample/tabs/custom_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkModeNotifier.isLightTheme
            ? switchAppThemeNotifier.currentTheme
            : darkBlack,
        elevation: 1.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: () {},
            icon: FaIcon(
              FontAwesomeIcons.bars,
              size: 20.0,
            ),
            color: white,
          ),
        ),
        actions: [
          InkWell(
            onTap: notifier.navigateAddCategoryScreen,
            child: Icon(
              Icons.folder_open,
              color: white,
            ),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: notifier.navigateSettingScreen,
            child: Icon(
              Icons.settings,
              color: white,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(groupNotifier.groupId)
                .collection('categories')
                .snapshots(),
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
                  itemCount: snapshot.data.docs.length,
                  tabBuilder: (context, index) {
                    notifier.setInitialTabId(snapshot.data.docs[index].id);
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 100,
                        maxHeight: 35,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorList[index],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Tab(
                          text: snapshot.data.docs[index].data()['name'],
                        ),
                      ),
                    );
                  },
                  pageBuilder: (context, index) {
                    return ColoredBox(
                      color: darkModeNotifier.isLightTheme
                          ? themeColor
                          : darkBlack,
                      child: createListView(
                        context: context,
                        categoryId: snapshot.data.docs[index].id,
                        index: index,
                      ),
                    );
                  },
                  onPositionChange: (index) {
                    notifier.setCurrentIndex(index);
                    notifier.initPosition = index;
                    notifier.updateCurrentTabId(snapshot.data.docs[index].id);
                  },
                  onScroll: (position) {},
                );
              }
            }),
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

  Widget createListView({
    BuildContext context,
    String categoryId,
    int index,
  }) {
    final notifier = Provider.of<HomeScreenNotifier>(context);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('categories')
          .doc(categoryId)
          .collection('to-dos')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError || snapshot.data == null) {
          return Container();
        } else {
          return ListView(
            children: snapshot.data.docs.map(
              (DocumentSnapshot document) {
                if (document == null) {
                  return Container();
                } else {
//                  final data = document.data;
//                  DateTime createdAt;
//                  var createdAtHour;
//                  if (data['createdAt'] is Timestamp) {
//                    createdAt = data['createdAt'].toDate();
//                    createdAtHour = createdAt.hour.toString() +
//                        ':' +
//                        createdAt.minute.toString();
//                  }
                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          dense: true,
                          leading: CircularCheckBox(
                            value: document['isChecked'],
                            checkColor: Colors.white,
                            activeColor: colorList[index],
                            inactiveColor: colorList[index],
                            disabledColor: Colors.grey,
                            onChanged: (val) {
                              notifier.updateTodoIsChecked(
                                'to-dos',
                                document.id,
                                !document['isChecked'],
                              );
                            },
                          ),
                          title: InkWell(
                            onTap: () {
                              notifier.editTodo(
                                collection: 'to-dos',
                                documentId: document.id,
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
                                        color: darkModeNotifier.isLightTheme
                                            ? black
                                            : white,
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
                                          document.id,
                                        );
//                                    notifier.editTodo(
//                                      collection: 'to-dos',
//                                      documentId: document.documentID,
//                                      initialValue: document['name'],
//                                    );
                                      },
                                      child: Hero(
                                        tag: document.id,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    )
                                  : null,
                          trailing: InkWell(
                            onTap: () {},
                            child: SizedBox(
                              height: 30,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  'assets/images/default_profile_image.png',
                                ),
                              ),
                            ),
                          ),
                        ),
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
