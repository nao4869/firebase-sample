import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/widgets/buttons/rounded_bottom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class FontSizePickerBottomSheet extends StatelessWidget {
  FontSizePickerBottomSheet({
    @required this.onPressedDone,
    this.onSelectedItemChanged,
    this.items,
    this.selectedIndex,
  });

  final VoidCallback onPressedDone;
  final Function onSelectedItemChanged;
  final List<String> items;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    return IntrinsicHeight(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
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
                    title: AppLocalizations.of(context)
                        .translate('completed'), //'完了',
                    radius: 50.0,
                    onPressed: onPressedDone,
                    style: const TextStyle(fontSize: 15, color: white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: CupertinoPicker(
                backgroundColor: white,
                itemExtent: 40,
                children: items.map(pickerItem).toList(),
                onSelectedItemChanged: onSelectedItemChanged,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ピッカー選択値表示関数
  Widget pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 32),
    );
  }
}
