import 'dart:io';

import 'package:firebase_sample/widgets/dialog/common_dialog.dart';
import 'package:flutter/material.dart';

class ShowConfirmDialogWidget extends StatelessWidget {
  const ShowConfirmDialogWidget({
    @required this.context,
    @required this.child,
  });

  final Widget child;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return WillPopScope(
        /// この画面でBackキーが押された場合に、いきなりアプリ終了させずに確認ダイアログ出します。
        // ignore: missing_return
        onWillPop: () {
          CmnDialog(context).showAppQuitConfirmDlg();
        },
        child: child,
      );
    }
    return child;
  }
}
