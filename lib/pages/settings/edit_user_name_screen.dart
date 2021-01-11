import 'dart:io';

import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/theme_provider.dart';
import 'package:firebase_sample/pages/settings/edit_user_name_screen_notifier.dart';
import 'package:firebase_sample/widgets/buttons/rounded_bottom_button.dart';
import 'package:firebase_sample/widgets/user/circular_user_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class EditUserNameScreen extends StatelessWidget {
  static String routeName = 'edit-user-name-screen';

  const EditUserNameScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditUserNameScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        themeNotifier: Provider.of(context, listen: false),
      ),
      child: _EditUserNameScreen(),
    );
  }
}

class _EditUserNameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<EditUserNameScreenNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    final keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    final safePadding = MediaQuery.of(context).padding.top;
    final buttonHeight = 50;
    final textFormHeight =
        size.height * .85 - keyBoardHeight - buttonHeight - safePadding;
    return ColoredBox(
      color: theme.isLightTheme ? white : darkBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: theme.isLightTheme ? white : darkBlack,
          appBar: AppBar(
            backgroundColor:
                theme.isLightTheme ? themeProvider.currentTheme : darkBlack,
            brightness: theme.isLightTheme ? Brightness.light : Brightness.dark,
            centerTitle: true,
            elevation: 1.0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              AppLocalizations.of(context).translate('editProfileTitle'),
              style: TextStyle(
                color: white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.check,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ColoredBox(
              color: theme.isLightTheme ? white : darkBlack,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      height: size.height,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(height: 15),
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: CircularUserIcon(
                                iconSize: .3,
                                imagePath: defaultImagePath,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FractionallySizedBox(
                            widthFactor: .9,
                            child: _buildTextFormField(
                              context,
                              formKey: notifier.formKey,
                              height: notifier.profileFocusNode.hasFocus
                                  ? textFormHeight
                                  : size.height * .7,
                              editingController: notifier.textController,
                              onValidate: notifier.onValidate,
                              onChanged: notifier.onChange,
                              resetTextField: notifier.resetTextField,
                            ),
//                            child: CustomTextFormField(
//                              formKey: notifier.nameFieldFormKey,
//                              height: notifier.textFormHeight,
//                              onValidate: notifier.onValidate,
//                              onChanged: notifier.onNameChange,
//                              hintText: AppLocalizations.of(context)
//                                  .translate('nameTitle'),
//                              initialValue: notifier.name,
//                              maxLines: 1,
//                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundedBottomButton(
                    isEnable: notifier.isValid,
                    title: AppLocalizations.of(context).translate('decide'),
                    color: themeProvider.currentTheme,
                    onPressed: () {},
                  ),
//                  SizedBox(
//                    width: size.width * .9,
//                    height: 50,
//                    child: RaisedButton(
//                      onPressed: () {},
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(10),
//                      ),
//                      color: themeProvider.currentTheme,
//                      child: Text(
//                        AppLocalizations.of(context).translate('decide'),
//                        style: TextStyle(
//                          color: white,
//                          fontSize: 20.0,
//                          fontWeight: FontWeight.bold,
//                        ),
//                      ),
//                    ),
//                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    BuildContext context, {
    GlobalKey<FormState> formKey,
    TextEditingController editingController,
    String Function(String) onValidate,
    ValueChanged<String> onChanged,
    VoidCallback resetTextField,
    double height,
  }) {
    final notifier = Provider.of<EditUserNameScreenNotifier>(context);
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final buttonSize = 20.0;
    return Form(
      key: notifier.formKey,
      child: SizedBox(
        height: height,
        child: TextFormField(
          autofocus: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          enabled: true,
          controller: editingController,
          validator: onValidate,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'User Name',
            hintStyle: const TextStyle(
              color: Color.fromRGBO(208, 208, 208, 1),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            suffix: SizedBox(
              height: buttonSize,
              width: buttonSize,
              child: RawMaterialButton(
                onPressed: () {
                  resetTextField();
                  editingController.clear();
                },
                child: Icon(
                  Icons.clear,
                  color: Colors.grey,
                  size: buttonSize,
                ),
              ),
            ),
            focusColor: pinky,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: themeProvider.currentTheme),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: themeProvider.currentTheme),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: themeProvider.currentTheme),
            ),
            errorStyle: const TextStyle(
              fontSize: 10.0,
              color: deepPink,
            ),
          ),
        ),
      ),
    );
  }
}
