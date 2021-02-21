import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class DateRow extends StatelessWidget {
  DateRow({
    this.remindDate,
    this.onPressed,
    this.onReset,
    this.sizeType,
  });

  final DateTime remindDate;
  final VoidCallback onPressed;
  final VoidCallback onReset;
  final ScreenSizeType sizeType;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    DateTime _remindDate = remindDate;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 40,
            width: size.width * .9,
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  AppLocalizations.of(context).translate('when'),
                  style: TextStyle(
                    fontSize: sizeType == ScreenSizeType.large ? 12.0 : 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  _remindDate != null
                      ? DateFormat.yMd().add_jm().format(_remindDate)
                      : AppLocalizations.of(context).translate('noRemindDate'),
                  style: TextStyle(
                    fontSize: sizeType == ScreenSizeType.large ? 12.0 : 15.0,
                    fontWeight: FontWeight.bold,
                    color: switchAppThemeNotifier.currentTheme,
                  ),
                ),
                const SizedBox(width: 8),
                _remindDate != null
                    ? InkWell(
                        onTap: () {
                          onReset();
                          _remindDate = null;
                          setState(() {});
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 20.0,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
