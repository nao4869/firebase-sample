import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
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
                  onTap: () {},
                  child: Icon(
                    Icons.check,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ColoredBox(
              color: theme.isLightTheme ? themeColor : darkBlack,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: notifier.updateUserProfileImage,
                      child: CircularUserIcon(
                        iconSize: .3,
                        imagePath: notifier.imagePath ?? defaultPersonImage,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FractionallySizedBox(
                    widthFactor: .8,
                    child: RoundedBottomButton(
                      isEnable: true,
                      title: AppLocalizations.of(context)
                          .translate('selectImageFromGallery'),
                      color: themeProvider.currentTheme,
                      onPressed: notifier.updateUserName,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        'Select from icons',
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            notifier.updateUserAssetProfile(
                                'assets/images/person_icon_${index + 1}.png');
                          },
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: Image.asset(
                              'assets/images/person_icon_${index + 1}.png',
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: 10);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: SizedBox(
                        height: 100,
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
                                width: 90,
                                height: 90,
                                child: Image.asset(
                                  'assets/images/person_icon_${index + 5}.png',
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(width: 15);
                          },
                        ),
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
}
