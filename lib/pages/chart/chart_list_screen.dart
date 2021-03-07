import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/chart/chart_list_screen_notifier.dart';
import 'package:firebase_sample/plugin/flutter_rounded_progress_bar.dart';
import 'package:firebase_sample/plugin/rounded_progress_bar_style.dart';
import 'package:firebase_sample/widgets/dialog/circular_progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChartListScreen extends StatelessWidget {
  const ChartListScreen();

  static String routeName = 'chart-list-screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChartListScreenNotifier(
        context: context,
        parentCategoryIdNotifier: Provider.of(context),
      ),
      child: _ChartListScreen(),
    );
  }
}

class _ChartListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ChartListScreenNotifier>(context);
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    final groupNotifier = Provider.of<CurrentGroupProvider>(context);
    final userNotifier = Provider.of<UserReferenceProvider>(context);
    final currentThemeId = switchAppThemeNotifier.getCurrentThemeNumber();
    return Scaffold(
      backgroundColor: switchAppThemeNotifier.currentTheme,
      appBar: AppBar(
        backgroundColor: darkModeNotifier.isLightTheme
            ? switchAppThemeNotifier.currentTheme
            : darkBlack,
        elevation: 1.0,
        title: Text(
          '達成済みタスク',
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
      ),
      body: notifier.parentCategoryIdNotifier.currentParentCategoryId != null &&
              notifier
                  .parentCategoryIdNotifier.currentParentCategoryId.isNotEmpty
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('versions')
                  .doc('v2')
                  .collection('groups')
                  .doc(groupNotifier.groupId)
                  .collection('categories')
                  .doc(
                      notifier.parentCategoryIdNotifier.currentParentCategoryId)
                  .collection('children')
                  .orderBy("createdAt",
                      descending:
                          userNotifier.isSortCategoryByCreatedAt ?? true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // エラーの場合
                if (snapshot.hasError || snapshot.data == null) {
                  return CircularProgressDialog();
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
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          // print(snapshot.data.size);
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Center(
                              child: FractionallySizedBox(
                                widthFactor:
                                    notifier.sizeType == ScreenSizeType.large
                                        ? .99
                                        : .95,
                                child: Card(
                                  color: white.withOpacity(0.9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0),
                                          child: Text(
                                            snapshot.data.docs[index]
                                                .data()['name'],
                                            style: TextStyle(
                                              color: black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('versions')
                                              .doc('v2')
                                              .collection('groups')
                                              .doc(groupNotifier.groupId)
                                              .collection('categories')
                                              .doc(notifier
                                                  .parentCategoryIdNotifier
                                                  .currentParentCategoryId)
                                              .collection('children')
                                              .doc(snapshot.data.docs[index].id)
                                              .collection('to-dos')
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  todoSnapShot) {
                                            // エラーの場合
                                            if (todoSnapShot.hasError ||
                                                todoSnapShot.data == null) {
                                              return CircularProgressDialog();
                                            } else {
                                              final completedPercent = notifier
                                                  .calculateCompletePercent(
                                                      todoSnapShot.data.docs);
                                              return Text(
                                                completedPercent.isNaN
                                                    ? '0.0%'
                                                    : completedPercent
                                                            .roundToDouble()
                                                            .toString() +
                                                        '%',
                                                style: TextStyle(
                                                  color: black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    subtitle: _buildRoundedProgressBar(
                                        context, index),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              })
          : Container(),
    );
  }

  Widget _buildRoundedProgressBar(
    BuildContext context,
    int index,
  ) {
    final theme = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RoundedProgressBar(
              height: 10,
              childLeft: Text(
                '${50}%',
                style: TextStyle(
                  color: theme.getThemeData == lightTheme
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              percent: 50.0,
              color: index >= colorList.length
                  ? colorList[index - colorList.length]
                  : colorList[index],
              style: RoundedProgressBarStyle(
                widthShadow: 30,
                colorBorder: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
