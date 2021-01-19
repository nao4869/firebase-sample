import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SelectDesignScreen extends StatefulWidget {
  SelectDesignScreen();

  @override
  _SelectDesignScreenState createState() => _SelectDesignScreenState();
}

class _SelectDesignScreenState extends State<SelectDesignScreen> {
  int selectedIndex = 0;
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    selectedIndex = themeProvider.getCurrentThemeNumber();
    return Scaffold(
      //bottomNavigationBar: banner,
      backgroundColor: theme.isLightTheme ? const Color(0xfff8f9fd) : black,
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme,
        brightness: Brightness.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context).translate('selectDesign'),
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  CmnDialog(context).showYesNoDialog(
                    titleStr: AppLocalizations.of(context)
                        .translate('selectingBackgroundImage'),
                    titleColor: themeProvider.currentTheme,
                    //msgStr: '変更はまだ保存されていません。',
                    onPositiveCallback: () {
                      // ポップ時にDBのアプリテーマを更新
//                      db.updateCurrentTheme(
//                        CurrentTheme(
//                          id: 0,
//                          themeNumber: selectedIndex,
//                        ),
//                        dbInstance,
//                      )
//
//                      // 色を選択した際には、画像のisImageSelectedの値も変更する
//                      db.updateTalkRoomImage(
//                        TalkBackgroundImage(
//                          id: 0,
//                          backGroundImagePath: '',
//                          isImageSelected: 0,
//                        ),
//                        dbInstance,
//                      );
                      Navigator.of(context).pop();
                    },
                    positiveBtnStr:
                        AppLocalizations.of(context).translate('apply'),
                    onNegativeCallback: null,
                    negativeBtnStr:
                        AppLocalizations.of(context).translate('cancel'),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).translate('select'),
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ColoredBox(
        color: themeColor,
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      _buildRoundedButton('Select from free design'),
                      const SizedBox(height: 20),
                      _buildDesignLisView(startIndex: 0),
                      const SizedBox(height: 20),
                      _buildDesignLisView(startIndex: 4),
                      const SizedBox(height: 20),
                      _buildImageLisView(
                        startIndex: 0,
                        length: 4,
                      ),
                      const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildRoundedButton(String title) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * .85,
      height: 50,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () {},
        color: black,
        child: Text(
          title,
          style: TextStyle(
            color: white,
          ),
        ),
      ),
    );
  }

  // 背景色表示用ListView
  Widget _buildDesignLisView({
    int startIndex = 0,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: size.width * .85,
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 80,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorList[index + startIndex],
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
    int startIndex = 0,
    int length = 0,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: size.width * .85,
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                imageList[index + startIndex],
                fit: BoxFit.cover,
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

  void popDialog() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
