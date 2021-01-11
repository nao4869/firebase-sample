import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DefaultAppBar extends StatelessWidget with PreferredSizeWidget {
  DefaultAppBar({
    this.drawerKey,
    this.leading,
    this.title,
    this.actions,
  });

  final GlobalKey<ScaffoldState> drawerKey;
  final Widget leading;
  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return AppBar(
      backgroundColor: theme.isLightTheme ? white : darkBlack,
      brightness: theme.isLightTheme ? Brightness.light : Brightness.dark,
      elevation: 1,
      centerTitle: true,
      leading: leading,
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
