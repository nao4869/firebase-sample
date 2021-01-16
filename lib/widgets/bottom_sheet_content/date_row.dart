import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateRow extends StatelessWidget {
  DateRow({
    this.createdDate,
    this.onPressed,
  });

  final String createdDate;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 40,
        width: size.width * .9,
        child: Row(
          children: [
            const SizedBox(width: 20),
            Text(
              'When?',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              createdDate != null
                  ? createdDate.substring(0, 10)
                  : 'No remind date',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: switchAppThemeNotifier.currentTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
