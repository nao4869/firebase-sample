import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({
    this.title,
    this.onPressed,
    this.height = .87,
  });

  final String title;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return SizedBox(
      width: size.width * height,
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
}
