import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/splash/user_registration_screen_notifier.dart';
import 'package:firebase_sample/widgets/buttons/rounded_bottom_button.dart';
import 'package:firebase_sample/widgets/user/user_registration_page_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class UserRegistrationScreen extends StatelessWidget {
  static String routeName = 'user-registration-screen';

  const UserRegistrationScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRegistrationScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
        themeNotifier: Provider.of(context, listen: false),
        groupNotifier: Provider.of(context, listen: false),
        userReference: Provider.of(context, listen: false),
      ),
      child: _UserRegistrationScreen(),
    );
  }
}

class _UserRegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<UserRegistrationScreenNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final textFormHeight = 80.0;
    return ColoredBox(
      color: theme.isLightTheme ? white : darkBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: theme.isLightTheme ? white : darkBlack,
          body: SafeArea(
            child: ColoredBox(
              color: theme.isLightTheme ? themeColor : darkBlack,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints:
                                const BoxConstraints.tightFor(height: 56.0),
                          ),
                          const SizedBox(height: 15),
                          FractionallySizedBox(
                            widthFactor: .8,
                            child: UserRegistrationPageTitle(
                              title: AppLocalizations.of(context)
                                  .translate('invitationCode'),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: .8,
                            child: _buildTextFormFieldDescription(
                              AppLocalizations.of(context)
                                  .translate('ifYouAreInvited'),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: .8,
                            child: _buildTextFormField(
                              context,
                              formKey: notifier.groupFormKey,
                              height: textFormHeight,
                              editingController: notifier.groupTextController,
                              onValidate: notifier.onValidate,
                              onChanged: notifier.onInvitationCodeChange,
                              resetTextField: notifier.resetTextField,
                              hintText: AppLocalizations.of(context)
                                  .translate('invitationCode'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundedBottomButton(
                    isEnable: true,
                    title: AppLocalizations.of(context).translate('register'),
                    color: themeProvider.currentTheme,
                    onPressed: notifier.checkInvitationCodeValidity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormFieldDescription(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: warmGrey,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
              letterSpacing: 1.2,
              height: 1.2,
            ),
            maxLines: 5,
            textAlign: TextAlign.left,
          ),
        ),
      ],
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
    String hintText,
  }) {
    final themeProvider = Provider.of<SwitchAppThemeProvider>(context);
    final buttonSize = 20.0;
    return Form(
      key: formKey,
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
            hintText: hintText,
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
