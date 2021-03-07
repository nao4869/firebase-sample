import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/chart/chart_list_screen.dart';
import 'package:firebase_sample/pages/home/home_screen.dart';
import 'package:firebase_sample/widgets/lifeCycles/show_confirm_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NavigationHolder {
  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> chatRoomNavigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> settingsNavigatorKey =
      GlobalKey<NavigatorState>();
}

class TabScreen extends StatefulWidget {
  static const routeName = 'tabs-screen';

  final String pageIndex;

  TabScreen({
    this.pageIndex,
  });

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _defaultIndex = 0;
  int _selectedIndex = 0;

  void _onTapHandler(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _defaultIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final myLocale = Localizations.localeOf(context);
    final language = myLocale.languageCode;
    return ShowConfirmDialogWidget(
        context: context,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.home,
                  color: warmGrey,
                ),
                activeIcon: Icon(
                  Icons.home,
                  color: themeProvider.currentTheme,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.bubble_chart_sharp,
                  color: warmGrey,
                ),
                activeIcon: Icon(
                  Icons.bubble_chart_sharp,
                  color: themeProvider.currentTheme,
                ),
              ),
            ],
            onTap: _onTapHandler,
            currentIndex: _selectedIndex,
            backgroundColor: theme.isLightTheme ? white : black,
            iconSize: 30,
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  navigatorKey: NavigationHolder.homeNavigatorKey,
                  builder: (context) {
                    return HomeScreen();
                  },
                );
              case 1:
                return CupertinoTabView(
                  builder: (context) {
                    return ChartListScreen();
                  },
                );
              default:
                {
                  return CupertinoTabView(
                    builder: (context) {
                      return HomeScreen();
                    },
                  );
                }
            }
          },
        ));
  }
}
