import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodoContent extends StatelessWidget {
  const TodoContent({
    this.onPressed,
    this.content,
    this.remindDate,
    this.createdDate,
    this.isChecked = false,
    this.sizeType,
  });

  final VoidCallback onPressed;
  final String content;
  final DateTime remindDate;
  final DateTime createdDate;
  final bool isChecked;
  final ScreenSizeType sizeType;

  @override
  Widget build(BuildContext context) {
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    final userSettingsNotifier = Provider.of<UserReferenceProvider>(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    content,
                    maxLines: 100,
                    style: TextStyle(
                      fontSize: userSettingsNotifier.todoFontSize,
                      color: darkModeNotifier.isLightTheme ? black : white,
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            remindDate != null
                ? Row(
                    children: [
                      Flexible(
                        child: Text(
                          DateFormat.yMMMd().add_jm().format(remindDate),
                          maxLines: 10,
                          style: TextStyle(
                            fontSize: userSettingsNotifier.todoFontSize,
                            color:
                                darkModeNotifier.isLightTheme ? black : white,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            userSettingsNotifier.isDisplayCreatedAt
                ? const SizedBox(height: 5)
                : Container(),
            userSettingsNotifier.isDisplayCreatedAt
                ? Row(
                    children: [
                      Flexible(
                        child: Text(
                          DateFormat.yMMMd().add_jm().format(createdDate),
                          maxLines: 10,
                          style: TextStyle(
                            fontSize: userSettingsNotifier.todoFontSize,
                            color:
                                darkModeNotifier.isLightTheme ? black : white,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
