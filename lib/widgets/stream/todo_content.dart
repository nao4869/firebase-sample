import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoContent extends StatelessWidget {
  const TodoContent({
    this.onPressed,
    this.content,
    this.isChecked = false,
  });

  final VoidCallback onPressed;
  final String content;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onPressed,
      child: Row(
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
    );
  }
}
