import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:firebase_sample/pages/settings/select_design_screen_notifier.dart';
import 'package:firebase_sample/widgets/buttons/rounded_button.dart';
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
        userReferenceNotifier: Provider.of(context, listen: false),
        groupNotifier: Provider.of(context, listen: false),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: size.width * .9,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            RoundedButton(
                              title: AppLocalizations.of(context)
                                  .translate('freeDesign'),
                              onPressed: () {},
                            ),
                            const SizedBox(height: 20),
                            _buildDesignLisView(
                              context: context,
                              startIndex: 0,
                            ),
                            const SizedBox(height: 10),
                            _buildDesignLisView(
                              context: context,
                              startIndex: 4,
                            ),
                            const SizedBox(height: 10),
                            _buildImageLisView(
                              context: context,
                              startIndex: 0,
                              length: 4,
                            ),
                            const SizedBox(height: 10),
                            _buildImageLisView(
                              context: context,
                              startIndex: 4,
                              length: 4,
                            ),
                            const SizedBox(height: 10),
                            _buildImageLisView(
                              context: context,
                              startIndex: 8,
                              length: 4,
                            ),
                            const SizedBox(height: 10),
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
              const SizedBox(height: 200),
            ],
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
    final notifier = Provider.of<SelectDesignScreenNotifier>(context);
    final switchAppThemeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: size.width * .85,
        height: notifier.tileSizeByDevice,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                switchAppThemeProvider
                    .switchTheme(colorList[index + startIndex]);
                notifier.updateThemeColor(
                  index,
                  '',
                );
              },
              child: SizedBox(
                width: notifier.tileSizeByDevice,
                height: notifier.tileSizeByDevice,
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
    final notifier = Provider.of<SelectDesignScreenNotifier>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: size.width * .85,
        height: notifier.tileSizeByDevice,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                notifier.updateThemeColor(
                  index + startIndex,
                  imageList[index + startIndex],
                );
              },
              child: SizedBox(
                width: notifier.tileSizeByDevice,
                height: notifier.tileSizeByDevice,
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
}
