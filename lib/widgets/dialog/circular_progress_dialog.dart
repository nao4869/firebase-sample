import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CircularProgressDialog extends StatelessWidget {
  const CircularProgressDialog();

  @override
  Widget build(BuildContext context) {
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          switchAppThemeNotifier.currentTheme,
        ),
      ),
    );
  }
}
