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
    final notifier = Provider.of<EditGroupNameScreenNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return Scaffold(
      key: notifier.scaffoldKey,
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
            const SizedBox(height: 30),
            _buildInvitePersonTile(context),
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
        stream: FirebaseFirestore.instance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // エラーの場合
          if (snapshot.hasError || snapshot.data == null) {
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
                            'Not Setting',
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
                                    initialValue: '',
                                    onUpdatePressed: () {
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
                                    onUpdatePressed: () {
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
    return [
      SettingTitle(
        title: AppLocalizations.of(context).translate('currentGroupMember'),
      ),
      StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .doc(groupNotifier.groupId)
            .collection('users')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // エラーの場合
          if (snapshot.hasError || snapshot.data == null) {
            return Container();
          } else {
            return ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 10);
              },
              itemCount: snapshot.data.size,
              itemBuilder: (BuildContext context, int index) {
                final imageWidget =
                    setImagePath(snapshot.data.docs[index].data()['imagePath']);
                return ColoredBox(
                  color: white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: notifier
                                    .switchAppThemeNotifier.currentTheme,
                                width: 10.0,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: imageWidget,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          snapshot.data.docs[index].data()['name'] ?? '',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    ];
  }

  Widget _buildInvitePersonTile(BuildContext context) {
    final notifier = Provider.of<EditGroupNameScreenNotifier>(context);
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: notifier.showInvitationMethodDialog,
      child: ColoredBox(
        color: white,
        child: SizedBox(
          width: size.width * .9,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/persons.png',
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Invite new person',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Share your todo list, shopping list with family members and friends',
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
