import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/widgets/buttons/rounded_bottom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DatePickerBottomSheet extends StatelessWidget {
  DatePickerBottomSheet({
    this.initialDateString,
    @required this.isValid,
    @required this.onPressedNext,
    @required this.onPressedDone,
    @required this.onDateTimeChanged,
  });

  final String initialDateString;
  final bool isValid;
  final VoidCallback onPressedNext;
  final VoidCallback onPressedDone;
  final ValueChanged<String> onDateTimeChanged;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    DateTime initialDate;
    int year;
    int month;
    int day;

    year = int.parse((DateFormat('yyyy')).format(DateTime.now()));

    if (initialDateString == '' || initialDateString == null) {
      month = int.parse((DateFormat('MM')).format(DateTime.now()));
      day = int.parse((DateFormat('dd')).format(DateTime.now()));

      initialDate = DateTime(year, month, day);
    } else {
      initialDate = DateTime.parse(initialDateString);
    }

    return IntrinsicHeight(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RoundedButton(
                    color: themeProvider.currentTheme,
                    title: 'Done', //'完了',
                    radius: 50.0,
                    onPressed: onPressedDone,
                    style: const TextStyle(fontSize: 15, color: white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: CupertinoDatePicker(
                backgroundColor: backgroundWhite,
                initialDateTime: initialDate,
                onDateTimeChanged: (DateTime value) {
                  onDateTimeChanged(
                    value.toIso8601String(),
                  );
                },
                mode: CupertinoDatePickerMode.date,
                maximumYear: (year + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
