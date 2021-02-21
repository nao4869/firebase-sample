import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/settings/edit_user_icon_screen_notifier.dart';
import 'package:firebase_sample/widgets/buttons/rounded_bottom_button.dart';
import 'package:firebase_sample/widgets/user/circular_user_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class EditUserIconScreen extends StatelessWidget {
  static String routeName = 'edit-user-icon-screen';

  const EditUserIconScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditUserIconScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        themeNotifier: Provider.of(context, listen: false),
        groupNotifier: Provider.of(context, listen: false),
        userReference: Provider.of(context, listen: false),
      ),
      child: _EditUserIconScreen(),
    );
  }
}

class _EditUserIconScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<EditUserIconScreenNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return ColoredBox(
      color: theme.isLightTheme ? white : darkBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: theme.isLightTheme ? white : darkBlack,
          appBar: AppBar(
            backgroundColor:
                theme.isLightTheme ? themeProvider.currentTheme : darkBlack,
            brightness: theme.isLightTheme ? Brightness.light : Brightness.dark,
            centerTitle: true,
            elevation: 1.0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              AppLocalizations.of(context).translate('editProfileTitle'),
              style: TextStyle(
                color: white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.check,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: IgnorePointer(
              ignoring: notifier.isUploadingImage ? true : false,
              child: Stack(
                children: [
                  notifier.isUploadingImage
                      ? Opacity(
                          opacity: notifier.isUploadingImage ? 1.0 : 0,
                          child: Center(
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  notifier.switchAppThemeNotifier.currentTheme,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Opacity(
                    opacity: notifier.isUploadingImage ? 0.3 : 1.0,
                    child: ColoredBox(
                      color: theme.isLightTheme ? themeColor : darkBlack,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('versions')
                                .doc('v2')
                                .collection('groups')
                                .doc(notifier.groupNotifier.groupId)
                                .collection('users')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              // エラーの場合
                              if (snapshot.hasError || snapshot.data == null) {
                                return Container();
                              } else {
                                // 該当ユーザーDocumentを取得
                                final doc = snapshot.data.docs.firstWhere(
                                    (element) =>
                                        element.id ==
                                        notifier.userReference.referenceToUser);
                                return Center(
                                  child: GestureDetector(
                                    onTap: notifier.updateUserProfileImage,
                                    child: CircularUserIcon(
                                      iconSize: .3,
                                      imagePath: doc.data()['imagePath'],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          FractionallySizedBox(
                            widthFactor: .8,
                            child: RoundedBottomButton(
                              isEnable: true,
                              title: AppLocalizations.of(context)
                                  .translate('selectImageFromGallery'),
                              color: themeProvider.currentTheme,
                              onPressed: notifier.updateUserProfileImage,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('selectFromIcons'),
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          _buildFirstIconsRow(context),
                          const SizedBox(height: 10),
                          _buildSecondIconsRow(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstIconsRow(BuildContext context) {
    final notifier = Provider.of<EditUserIconScreenNotifier>(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: SizedBox(
          height: notifier.sizeType == ScreenSizeType.large ? 80 : 100,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  InkWell(
                    onTap: () {
                      notifier.updateUserAssetProfile(
                          'assets/images/person_icon_${index + 1}.png');
                    },
                    child: SizedBox(
                      width:
                          notifier.sizeType == ScreenSizeType.large ? 70 : 90,
                      height:
                          notifier.sizeType == ScreenSizeType.large ? 70 : 90,
                      child: Image.asset(
                        'assets/images/person_icon_${index + 1}.png',
                      ),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 10);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSecondIconsRow(BuildContext context) {
    final notifier = Provider.of<EditUserIconScreenNotifier>(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: SizedBox(
          height: notifier.sizeType == ScreenSizeType.large ? 80 : 100,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  notifier.updateUserAssetProfile(
                      'assets/images/person_icon_${index + 5}.png');
                },
                child: SizedBox(
                  width: notifier.sizeType == ScreenSizeType.large ? 70 : 90,
                  height: notifier.sizeType == ScreenSizeType.large ? 70 : 90,
                  child: Image.asset(
                    'assets/images/person_icon_${index + 5}.png',
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 10);
            },
          ),
        ),
      ),
    );
  }
}
