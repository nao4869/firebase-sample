import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/settings/select_design_screen_notifier.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SelectDesignScreen extends StatelessWidget {
  static String routeName = 'select-design-screen';

  const SelectDesignScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SelectDesignScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        themeNotifier: Provider.of(context, listen: false),
      ),
      child: _SelectDesignScreen(),
    );
  }
}

class _SelectDesignScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final switchAppThemeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final currentThemeId = switchAppThemeProvider.getCurrentThemeNumber();
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color:
              currentThemeId < 9 ? switchAppThemeProvider.currentTheme : white,
          image: switchAppThemeProvider.selectedImagePath.isNotEmpty
              ? DecorationImage(
                  image: AssetImage(imageList[currentThemeId]),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: size.width * .9,
                    height: size.height * .7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildRoundedButton(context, 'Free design'),
                          const SizedBox(height: 20),
                          _buildDesignLisView(startIndex: 0),
                          const SizedBox(height: 10),
                          _buildDesignLisView(startIndex: 4),
                          const SizedBox(height: 10),
                          _buildImageLisView(
                            startIndex: 0,
                            length: 4,
                          ),
                          const SizedBox(height: 10),
                          _buildImageLisView(
                            startIndex: 4,
                            length: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * .42,
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        color: switchAppThemeProvider.currentTheme,
                        width: 3,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    elevation: 0.0,
                    color: white,
                    child: Text(
                      AppLocalizations.of(context).translate('cancel'),
                      style: TextStyle(
                        color: switchAppThemeProvider.currentTheme,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: size.width * .42,
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        color: white,
                        width: 3,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    elevation: 0.0,
                    color: switchAppThemeProvider.currentTheme,
                    child: Text(
                      AppLocalizations.of(context).translate('save'),
                      style: TextStyle(
                        color: white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedButton(
    BuildContext context,
    String title,
  ) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return SizedBox(
      width: size.width * .87,
      height: 50,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () {},
        color: switchAppThemeProvider.currentTheme,
        child: Text(
          title,
          style: TextStyle(
            color: white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  // 背景色表示用ListView
  Widget _buildDesignLisView({
    BuildContext context,
    int startIndex = 0,
  }) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: size.width * .85,
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                switchAppThemeProvider.switchTheme(
                  colorList[index + startIndex],
                );
              },
              child: SizedBox(
                width: 80,
                height: 80,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorList[index + startIndex],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 10);
          },
        ),
      ),
    );
  }

  // 背景画像表示用ListView
  Widget _buildImageLisView({
    BuildContext context,
    int startIndex = 0,
    int length = 0,
  }) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: size.width * .85,
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                switchAppThemeProvider.updateSelectedImagePath(
                  imageList[index + startIndex],
                );
              },
              child: SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    imageList[index + startIndex],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 10);
          },
        ),
      ),
    );
  }

  void popDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
