import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodoContent extends StatelessWidget {
  const TodoContent({
    this.onPressed,
    this.content,
    this.remindDate,
    this.isChecked = false,
  });

  final VoidCallback onPressed;
  final String content;
  final DateTime remindDate;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                      content,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: darkModeNotifier.isLightTheme ? black : white,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            remindDate != null
                ? Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            DateFormat.yMMMd().add_jm().format(remindDate),
                            maxLines: 10,
                            style: TextStyle(
                              fontSize: 15.0,
                              color:
                                  darkModeNotifier.isLightTheme ? black : white,
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
