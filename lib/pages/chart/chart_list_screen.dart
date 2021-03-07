import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/current_parent_category_id.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/chart/chart_list_screen_notifier.dart';
import 'package:firebase_sample/plugin/flutter_rounded_progress_bar.dart';
import 'package:firebase_sample/plugin/rounded_progress_bar_style.dart';
import 'package:firebase_sample/widgets/stream/tagged_user_image.dart';
import 'package:firebase_sample/widgets/stream/todo_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor:
                      notifier.sizeType == ScreenSizeType.large ? .99 : .95,
                  child: Card(
                    color: white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'カテゴリー名称',
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            '50%',
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      subtitle: _buildRoundedProgressBar(context, 1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createListView({
    BuildContext context,
    String categoryId,
    int index,
  }) {
    final notifier = Provider.of<ChartListScreenNotifier>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final parentIdNotifier =
        Provider.of<CurrentParentCategoryIdProvider>(context, listen: false);
    final userNotifier = Provider.of<UserReferenceProvider>(context);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('versions')
          .doc('v2')
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('categories')
          .doc(parentIdNotifier.currentParentCategoryId)
          .collection('children')
          .doc(categoryId)
          .collection('to-dos')
          .orderBy("createdAt",
              descending: userNotifier.isSortByCreatedAt ?? true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError || snapshot.data == null) {
          return Container();
        } else {
          notifier.updateTodoList(snapshot.data.docs);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: MaterialClassicHeader(
                  color: switchAppThemeNotifier.currentTheme,
                ),
                controller: notifier.refreshController,
                onRefresh: notifier.onRefresh,
                onLoading: notifier.onLoading,
                child: ListView(
                  children: notifier.todoList.map(
                    (DocumentSnapshot document) {
                      if (document == null) {
                        return Container();
                      } else {
                        final userReference = document['taggedUserReference'];
                        return Column(
                          children: [
                            FractionallySizedBox(
                              widthFactor:
                                  notifier.sizeType == ScreenSizeType.large
                                      ? .99
                                      : .95,
                              child: Slidable(
                                key: Key(document.id),
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 1.0,
                                dismissal: SlidableDismissal(
                                  child: SlidableDrawerDismissal(),
                                  onDismissed: (actionType) {
                                    notifier.showSnackBar(
                                      context,
                                      actionType == SlideActionType.primary
                                          ? 'Dismiss Archive'
                                          : 'Todo deleted',
                                    );
                                    notifier.deleteTodo(
                                      'to-dos',
                                      document.id,
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
                                child: Card(
                                  color: white.withOpacity(0.9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    leading: userNotifier.isDisplayCheckBox
                                        ? SizedBox(
                                            width: 40,
                                            child: CircularCheckBox(
                                              value: document['isChecked'],
                                              checkColor: Colors.white,
                                              activeColor:
                                                  index >= colorList.length
                                                      ? colorList[0]
                                                      : colorList[index],
                                              inactiveColor:
                                                  index >= colorList.length
                                                      ? colorList[0]
                                                      : colorList[index],
                                              disabledColor: Colors.grey,
                                              onChanged: (val) {
                                                notifier.updateTodoIsChecked(
                                                  'to-dos',
                                                  document.id,
                                                  !document['isChecked'],
                                                );
                                              },
                                            ),
                                          )
                                        : null,
                                    title: TodoContent(
                                      onPressed: () {
                                        notifier.editTodo(
                                          collection: 'to-dos',
                                          documentId: document.id,
                                          initialValue: document['name'],
                                          selectedPersonId: document[
                                                      'taggedUserReference'] !=
                                                  null
                                              ? document['taggedUserReference']
                                                  .id
                                              : null,
                                          remindDate: document['remindDate'] !=
                                                  null
                                              ? document['remindDate'].toDate()
                                              : null,
                                        );
                                      },
                                      content: document['name'] ?? '',
                                      remindDate: document['remindDate'] != null
                                          ? document['remindDate'].toDate() ??
                                              ''
                                          : null,
                                      createdDate: document['createdAt'] != null
                                          ? document['createdAt'].toDate() ?? ''
                                          : null,
                                      isChecked: document['isChecked'],
                                      sizeType: notifier.sizeType,
                                    ),
                                    trailing: userReference != null
                                        ? TaggedUserImage(
                                            taggedUserReferenceId:
                                                userReference.id,
                                            sizeType: notifier.sizeType,
                                          )
                                        : null,
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
              ),
            ),
          );
        }
      },
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
              color: colorList[index],
//              style: RoundedProgressBarStyle(
//                widthShadow: 30,
//                colorBorder: Theme.of(context).primaryColor,
//              ),
            ),
          ),
        ],
      ),
    );
  }
}
