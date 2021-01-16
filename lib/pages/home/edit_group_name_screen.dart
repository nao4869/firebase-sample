import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/home/edit_group_name_screen_notifier.dart';
import 'package:firebase_sample/pages/settings/setting_row.dart';
import 'package:firebase_sample/widgets/bottom_sheet/edit_category_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_sample/extensions/set_image_path.dart';

import '../../app_localizations.dart';

class EditGroupNameScreen extends StatelessWidget {
  static String routeName = 'edit-group-name-screen';

  const EditGroupNameScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditGroupNameScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        themeNotifier: Provider.of(context, listen: false),
      ),
      child: _EditGroupNameScreen(),
    );
  }
}

class _EditGroupNameScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.isLightTheme ? themeColor : darkBlack,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: switchAppThemeNotifier.currentTheme,
        title: Text(
          'Group Name',
          style: TextStyle(
            color: white,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            ...buildProfileSection(context),
            const SizedBox(height: 20),
            ...buildAppSettingsSection(context),
            const SizedBox(height: 30)
          ],
        ),
      ),
    );
  }

  List<Widget> buildProfileSection(BuildContext context) {
    final notifier = Provider.of<EditGroupNameScreenNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final groupNotifier = Provider.of<CurrentGroupProvider>(context);
    return [
      SettingTitle(
        title: AppLocalizations.of(context).translate('groupName'),
      ),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // エラーの場合
          if (snapshot.hasError || snapshot.data == null) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                notifier.switchAppThemeNotifier.currentTheme,
              ),
            );
          } else {
            DocumentSnapshot currentGroup = snapshot.data.docs.firstWhere(
                (element) => element.id == groupNotifier.groupId,
                orElse: null);
            return ColoredBox(
              color: white,
              child: InkWell(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 12.0,
                        bottom: 12.0,
                        left: 20.0,
                        right: 25.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            currentGroup != null
                                ? currentGroup['name']
                                : 'Not Setting',
                            style: TextStyle(
                              color: theme.isLightTheme ? black : white,
                              fontSize: 16.0,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return EditCategoryBottomSheet(
                                    buttonTitle: 'Update Group Name',
                                    initialValue: currentGroup['name'],
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      notifier.updateGroupName();
                                    },
                                    onNameChange: (String text) {
                                      notifier.onNameChange(text);
                                    },
                                  );
                                },
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('editGroupName'),
                              style: TextStyle(
                                color: notifier
                                    .switchAppThemeNotifier.currentTheme,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 20,
                      thickness: .5,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    ];
  }

  List<Widget> buildAppSettingsSection(BuildContext context) {
    final notifier = Provider.of<EditGroupNameScreenNotifier>(context);
    final groupNotifier = Provider.of<CurrentGroupProvider>(context);
    final size = MediaQuery.of(context).size;
    return [
      SettingTitle(
        title: AppLocalizations.of(context).translate('currentGroupMember'),
      ),
      StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupNotifier.groupId)
            .collection('users')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // エラーの場合
          if (snapshot.hasError || snapshot.data == null) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                notifier.switchAppThemeNotifier.currentTheme,
              ),
            );
          } else {
            return ColoredBox(
              color: white,
              child: SizedBox(
                height: 60,
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 10);
                    },
                    itemCount: snapshot.data.size,
                    itemBuilder: (BuildContext context, int index) {
                      final imageWidget = setImagePath(
                          snapshot.data.docs[index].data()['imagePath']);
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  notifier.switchAppThemeNotifier.currentTheme,
                              width: 10.0,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: imageWidget,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    ];
  }
}
