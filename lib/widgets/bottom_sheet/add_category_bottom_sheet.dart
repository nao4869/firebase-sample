import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/widgets/buttons/raised_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class AddCategoryBottomSheet extends StatelessWidget {
  AddCategoryBottomSheet({
    this.onPressed,
    this.onNameChange,
  });

  final VoidCallback onPressed;
  final Function(String) onNameChange;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: size.width * .85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.width * .1,
              width: size.width * .9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  maxLines: 20,
                  autofocus: true,
                  onChanged: onNameChange,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: size.width * .9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonRaisedButton(
                    title:
                        AppLocalizations.of(context).translate('addCategory'),
                    onPressed: onPressed,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
