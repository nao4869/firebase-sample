import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommonRaisedButton extends StatelessWidget {
  CommonRaisedButton({
    this.title,
    this.onPressed,
  });

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return RaisedButton(
      onPressed: onPressed,
      color: switchAppThemeNotifier.currentTheme,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
