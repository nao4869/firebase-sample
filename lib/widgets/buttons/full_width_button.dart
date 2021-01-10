import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullWidthButton extends StatelessWidget {
  FullWidthButton({
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
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
