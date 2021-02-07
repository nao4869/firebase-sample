import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/user_reference_provider.dart';
import 'package:firebase_sample/pages/settings/setting_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SwitchToggleListTile extends StatelessWidget {
  const SwitchToggleListTile({
    this.onChanged,
    this.switchFieldName,
  });

  final Function onChanged;
  final String switchFieldName;

  @override
  Widget build(BuildContext context) {
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final userNotifier =
        Provider.of<UserReferenceProvider>(context, listen: false);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .doc(userNotifier.referenceToUser)
          .collection('userSettings')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError || snapshot.data == null) {
          return SettingRow(
            title: AppLocalizations.of(context).translate(switchFieldName),
            onChange: onChanged,
            isEnable: false,
          );
        } else {
          DocumentSnapshot currentUserSetting = snapshot?.data?.docs?.first;
          return SettingRow(
            title: AppLocalizations.of(context).translate(switchFieldName),
            onChange: onChanged,
            isEnable: currentUserSetting[switchFieldName] ?? false,
          );
        }
      },
    );
  }
}
