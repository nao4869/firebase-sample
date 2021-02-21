import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen_notifier.dart';
import 'package:firebase_sample/tabs/custom_tab_bar.dart';
import 'package:firebase_sample/widgets/dialog/circular_progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen();

  static String routeName = 'category-photo-screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddCategoryScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        parentCategoryIdNotifier: Provider.of(context),
        userNotifier: Provider.of(context),
      ),
      child: _CategoryPhotoScreen(),
    );
  }
}

class _CategoryPhotoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier =
        Provider.of<AddCategoryScreenNotifier>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final currentThemeId =
        notifier.switchAppThemeNotifier.getCurrentThemeNumber();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.isLightTheme ? themeColor : darkBlack,
      appBar: AppBar(
        backgroundColor: notifier.switchAppThemeNotifier.currentTheme,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: white,
          ),
          color: notifier.switchAppThemeNotifier.currentTheme,
          iconSize: 30.0,
          onPressed: notifier.pop,
        ),
        title: Text(
          AppLocalizations.of(context).translate('manageCategory'),
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                notifier.displayParentCategoryActionSheet();
              },
              child: Icon(
                Icons.folder_open,
                color: white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                notifier.openModalBottomSheet(true);
              },
              child: Icon(
                Icons.add,
                color: white,
                size: 30.0,
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('versions')
              .doc('v2')
              .collection('groups')
              .doc(groupNotifier.groupId)
              .collection('categories')
              .orderBy("createdAt",
                  descending:
                      notifier.userNotifier.isSortCategoryByCreatedAt ?? true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // エラーの場合
            if (snapshot.hasError || snapshot.data == null) {
              return CircularProgressDialog();
            } else {
              return DecoratedBox(
                decoration: BoxDecoration(
                  image: notifier
                          .switchAppThemeNotifier.selectedImagePath.isNotEmpty
                      ? DecorationImage(
                          image: AssetImage(
                            imageList[currentThemeId],
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: darkModeNotifier.isLightTheme
                      ? notifier.switchAppThemeNotifier.currentTheme
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
                        maxWidth: 250,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: index >= colorList.length
                              ? colorList[0]
                              : colorList[index],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Tab(
                            text:
                                snapshot.data.docs[index].data()['name'] ?? '',
                          ),
                        ),
                      ),
                    );
                  },
                  pageBuilder: (context, index) {
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('versions')
                          .doc('v2')
                          .collection('groups')
                          .doc(groupNotifier.groupId)
                          .collection('categories')
                          .doc(notifier.currentTabDocumentId)
                          .collection('children')
                          .orderBy("createdAt",
                              descending: notifier
                                      .userNotifier.isSortCategoryByCreatedAt ??
                                  true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        // エラーの場合
                        if (snapshot.hasError || snapshot.data == null) {
                          return CircularProgressDialog();
                        } else {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.docs.length != 0
                                      ? snapshot.data.docs.length
                                      : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Slidable(
                                      key: Key(snapshot.data.docs[index].id),
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: 1.0,
                                      dismissal: SlidableDismissal(
                                        closeOnCanceled: true,
                                        child: SlidableDrawerDismissal(),
                                        onWillDismiss: (actionType) {
                                          return showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return notifier
                                                  .deleteConfirmDialog(
                                                actionType,
                                                snapshot.data.docs[index].id,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      secondaryActions: <Widget>[
                                        IconSlideAction(
                                          caption: 'Delete',
                                          color: Colors.red,
                                          icon: Icons.delete,
                                          onTap: () => notifier.showSnackBar(
                                            context,
                                            'Delete',
                                          ),
                                        ),
                                      ],
                                      child: GestureDetector(
                                        onTap: () {
                                          notifier.displayActionSheet(
                                            actionType: SlideActionType.primary,
                                            collection: 'children',
                                            documentId:
                                                snapshot.data.docs[index].id,
                                            initialValue: snapshot
                                                .data.docs[index]
                                                .data()['name'],
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: size.width * .7,
                                            height: notifier.sizeType ==
                                                    ScreenSizeType.large
                                                ? 40
                                                : 50,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: theme.isLightTheme
                                                    ? white
                                                    : black,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: index >=
                                                                colorList.length
                                                            ? colorList[0]
                                                            : colorList[index],
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    width: size.width * .7,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              snapshot
                                                                          .data
                                                                          .docs[
                                                                              index]
                                                                          .data()[
                                                                      'name'] ??
                                                                  '',
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                color: darkModeNotifier
                                                                        .isLightTheme
                                                                    ? black
                                                                    : white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: notifier
                                                                            .sizeType ==
                                                                        ScreenSizeType
                                                                            .large
                                                                    ? 12.0
                                                                    : 16.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                  onPositionChange: (index) {
                    notifier.setCurrentIndex(index);
                    notifier.initPosition = index;
                    notifier.updateCurrentTabId(
                      categoryId: snapshot.data.docs[index].id,
                      categoryName:
                          snapshot.data.docs[index].data()['name'] ?? '',
                    );
                  },
                  onScroll: (position) {},
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        elevation: 1.0,
        backgroundColor: white,
        onPressed: () {
          notifier.openModalBottomSheet(false);
        },
        child: Icon(
          Icons.add,
          color: notifier.switchAppThemeNotifier.currentTheme,
        ),
      ),
    );
  }
}
