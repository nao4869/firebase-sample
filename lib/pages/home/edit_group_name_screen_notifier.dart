import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:firebase_sample/pages/settings/edit_user_icon_screen.dart';
import 'package:firebase_sample/pages/settings/edit_user_name_screen.dart';
import 'package:firebase_sample/widgets/buttons/rounded_bottom_button.dart';
import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app_localizations.dart';

class EditGroupNameScreenNotifier extends ChangeNotifier {
  EditGroupNameScreenNotifier({
    this.context,
    this.switchAppThemeNotifier,
    this.themeNotifier,
  }) {
    //
  }

  final BuildContext context;
  final SwitchAppThemeProvider switchAppThemeNotifier;
  final ThemeProvider themeNotifier;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  String groupName;
  bool isValid = false;

  // ダークモード切り替え関数
  void updateDarkMode(bool val) {
    themeNotifier.setThemeData = !val;
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    groupName = text;
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    groupName = '';
    notifyListeners();
  }

  void navigateEditUserNameScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditUserNameScreen(),
      ),
    );
  }

  void navigateEditUserIconScreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => EditUserIconScreen(),
      ),
    );
  }

  void updateGroupName() {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('versions')
        .doc('v1')
        .collection('groups')
        .doc(groupNotifier.groupId)
        .update({'name': groupName});
  }

  Future<void> copyIdToClipBoard() async {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    // 一時的にクリップボードにデータをコピー
    final data = ClipboardData(
      text: groupNotifier.groupId,
    );
    await Clipboard.setData(data);
    scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('Group id has copied')),
    );
  }

  void showInvitationMethodDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) {
        return CmnDialog(context).showDialogWidget(
          onPositiveCallback: showQrCodeDialog,
          onNegativeCallback: showGroupIdDialog,
          titleStr: AppLocalizations.of(context).translate('invitationMethod'),
          titleColor: switchAppThemeNotifier.currentTheme,
          positiveBtnStr:
              AppLocalizations.of(context).translate('inviteByQrCode'),
          negativeBtnStr:
              AppLocalizations.of(context).translate('inviteByGroupId'),
        );
      },
    );
  }

  void showGroupIdDialog() {
    final switchAppThemeNotifier =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                children: <Widget>[
                  Text(
                    'Group ID',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * .005),
              Row(
                children: <Widget>[
                  Text(
                    groupNotifier.groupId,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      color: black,
                    ),
                  ),
                  IconButton(
                    onPressed: copyIdToClipBoard,
                    icon: Icon(Icons.copy),
                    iconSize: 15.0,
                    color: switchAppThemeNotifier.currentTheme,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                height: 1,
                child: ColoredBox(
                  color: switchAppThemeNotifier.currentTheme,
                ),
              ),
            ],
          ),
          content: Text(
            'Steps for joining\n\n(Invited person)\n1. Download the app\n2. Enter above group id when registering',
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0.0),
          actions: <Widget>[
            RoundedBottomButton(
              isEnable: true,
              title: 'Okay',
              color: switchAppThemeNotifier.currentTheme,
              onPressed: () {
                scaffoldKey.currentState.removeCurrentSnackBar();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showQrCodeDialog() {
    final switchAppThemeNotifier =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: SizedBox(
            width: size.width * .7,
            height: size.width * .7,
            child: QrImage(
              data: groupNotifier.groupId,
              backgroundColor: white,
              foregroundColor: switchAppThemeNotifier.currentTheme,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
          ),
          content: Text(
            'Steps for joining\n\n(Invited person)\n1. Download the app\n2. Scan QR code by camera or QR code reader',
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0.0),
          actions: <Widget>[
            RoundedBottomButton(
              isEnable: true,
              title: 'Okay',
              color: switchAppThemeNotifier.currentTheme,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
