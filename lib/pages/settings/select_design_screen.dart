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
//                      );
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
        color: theme.isLightTheme ? backgroundWhite : black,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: .5,
            mainAxisSpacing: .5,
          ),
          itemCount: colorList.length,
          itemBuilder: (BuildContext context, int index) {
            return index == selectedIndex
                ? Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: size.width * .4,
                            height: size.width * .332,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorList[index],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.black54,
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      themeProvider.switchTheme(colorList[index]);
                      selectedIndex = index;
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorList[index],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  void popDialog() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
