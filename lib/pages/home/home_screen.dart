import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/home/home_screen_notifier.dart';
import 'package:firebase_sample/tabs/custom_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_sample/extensions/set_image_path.dart';

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
    final groupNotifier = Provider.of<CurrentGroupProvider>(context);
    final currentThemeId = switchAppThemeNotifier.getCurrentThemeNumber();
    return Scaffold(
      backgroundColor: switchAppThemeNotifier.currentTheme,
      appBar: AppBar(
        backgroundColor: darkModeNotifier.isLightTheme
            ? switchAppThemeNotifier.currentTheme
            : darkBlack,
        elevation: 1.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: notifier.navigateEditGroupNameScreen,
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
                .collection('versions')
                .doc('v1')
                .collection('groups')
                .doc(groupNotifier.groupId)
                .collection('categories')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // エラーの場合
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      switchAppThemeNotifier.currentTheme,
                    ),
                  ),
                );
              } else {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    image: switchAppThemeNotifier.selectedImagePath.isNotEmpty
                        ? DecorationImage(
                            image: AssetImage(
                              imageList[currentThemeId],
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: darkModeNotifier.isLightTheme
                        ? switchAppThemeNotifier.currentTheme
                        : darkBlack,
                  ),
                  child: CustomTabView(
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
                      return createListView(
                        context: context,
                        categoryId: snapshot.data.docs[index].id,
                        index: index,
                      );
                    },
                    onPositionChange: (index) {
                      notifier.setCurrentIndex(index);
                      notifier.initPosition = index;
                      notifier.updateCurrentTabId(snapshot.data.docs[index].id);
                    },
                    onScroll: (position) {},
                  ),
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1.0,
        backgroundColor: white,
        onPressed: () async {
          notifier.openModalBottomSheet();
        },
        child: Icon(
          Icons.add,
          color: switchAppThemeNotifier.currentTheme,
        ),
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
          .collection('versions')
          .doc('v1')
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
          notifier.updateTodoList(snapshot.data.docs);
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: ListView(
              children: notifier.todoList.map(
                (DocumentSnapshot document) {
                  if (document == null) {
                    return Container();
                  } else {
                    final imageWidget = setImagePath(document['userImagePath']);
                    return Column(
                      children: [
                        FractionallySizedBox(
                          widthFactor: .95,
                          child: Card(
                            color: white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                          future: notifier
                                              .initializeVideoPlayerFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return InkWell(
                                                onTap:
                                                    notifier.playAndPauseVideo,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
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
                                  height: 35,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: imageWidget,
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
            ),
          );
        }
      },
    );
  }
}
