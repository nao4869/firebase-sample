import 'dart:io'; // OS種別等
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/constants/texts.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///--- Constant : ダイアログの共通定義地です ------------------------
// ダイアログ角丸R値
const double DIALOG_CORNER_ROUND = 32.0;
// ダイアログタイトル文字色
const Color COLOR_DLGTITLE_TEXT = COLOR_CONCEPT;
// ダイアログ本文文字色
const Color COLOR_DLGMESSAGE_TEXT = COLOR_TEXT_TONEDOWN;
// ダイアログボタン アクセント強め
const Color COLOR_DLGBTN_ACCENT_STRONG = COLOR_CONCEPT;
// ダイアログボタン アクセント弱め
const Color COLOR_DLGBTN_ACCENT_WEAK = COLOR_CONCEPT_WEAK;
// ダイアログボタン キャンセル・閉じる系
const Color COLOR_DLGBTN_ACCENT_NONE = COLOR_TEXT_TONEDOWN;
// ダイアログタイトル 文字サイズ
const double FONTSIZE_DLG_TITLE = 18;
// ダイアログ本文 文字サイズ
const double FONTSIZE_DLG_MSG = 16;
// ダイアログタイトル 文字Weight（太さ）
const FontWeight FONTWEIGHT_DLG_TITLE = FontWeight.w700;
// ダイアログ本文 文字Weight（太さ）
const FontWeight FONTWEIGHT_DLG_MSG = FontWeight.w400;

// 画像高さデフォルト
const double IMAGE_HEIGHT_DEFAULT = 100.0;

class CmnDialog {
  /// コンストラクタ
  /// @param	BuildContext
  CmnDialog(this.context);

  ///--- member -----
  final BuildContext context;

  void showConfirmDialog({
    String msgStr,
    String titleStr,
    Color titleColor,
    Widget bottomSection,
    String confirmBtnStr,
    bool isConfirmBtnCloseDialog = true,
    bool isBackKeyEnable = true,
    String imagePath,
    double imageHeight = IMAGE_HEIGHT_DEFAULT,
    double imageWidth,
    Color btnTextColor,
    Color btnBgColor,
    Function onConfirmCallback,
  }) {
    // ボタン文字列が未指定の場合はデフォルト文字列設定
    confirmBtnStr = confirmBtnStr ?? ''; // タイトル
    imageWidth = imageWidth ?? imageHeight; // 幅指定なしの場合は、高さと同一

    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            /// 物理Backキー押下でのダイアログクローズを許容するか？
            if (isBackKeyEnable) {
              Navigator.of(context, rootNavigator: true).pop(); // ダイアログ閉じる
            }
            return;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(DIALOG_CORNER_ROUND), // Dialog自体の四隅角丸設定
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // ダイアログ表示物のパディング値の設定
                horizontal: 30,
                vertical: 10,
              ),
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ), // スペーサー

                      // 画像表示
                      getImageWidget(imagePath, imageHeight, width: imageWidth),
                      if (null != imagePath)
                        const SizedBox(
                          height: 10,
                        ), // スペーサー

                      // ダイアログタイトル表示設定
                      _getTitleTextWidget(
                        titleStr: titleStr,
                        titleColor: titleColor,
                      ),
                      if (null != titleStr)
                        const SizedBox(
                          height: 20,
                        ), // Title が設定されているなら、スペース空ける

                      // ダイアログメッセージ本文表示設定
                      _getMsgTextWidget(msgStr: msgStr),
                      if (null != msgStr)
                        const SizedBox(
                          height: 30,
                        ), // 本文が設定されているなら、スペース空ける

                      if (null != bottomSection) bottomSection,
                      if (null != bottomSection)
                        const SizedBox(height: 30), // 本文が設定されているなら、スペース空ける

                      //--- 以下ボタンエリア -----------------
                      Column(
                        children: <Widget>[
                          _getBtn(
                              // NegativeButton
                              btnStr: confirmBtnStr,
                              btnBgColor: btnBgColor,
                              isCloseDialog: isConfirmBtnCloseDialog,
                              btnTextColor:
                                  btnTextColor ?? COLOR_DLGBTN_ACCENT_NONE,
                              onPressedCallback: onConfirmCallback),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showYesNoDialog({
    @required Function onPositiveCallback,
    String msgStr,
    String titleStr,
    Color titleColor,
    String imagePath,
    String imageUrl,
    double imageHeight = IMAGE_HEIGHT_DEFAULT,
    double imageWidth,
    String positiveBtnStr,
    String negativeBtnStr,
    bool isPositiveCloseDialog = true,
    Function onNegativeCallback,
  }) {
    final themeProvider =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    // 以下未指定時のデフォルト設定
    positiveBtnStr = positiveBtnStr ?? yes; // 肯定ボタン文字列
    negativeBtnStr = negativeBtnStr ?? cancel; // 否定ボタン文字列
    imageWidth = imageWidth ?? imageHeight; // 幅指定なしの場合は、高さと同一

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: theme.isLightTheme ? white : black,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DIALOG_CORNER_ROUND), // Dialog自体の四隅角丸設定
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
            ),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ), // スペーサー

                    // 画像表示
                    getImageWidget(imagePath, imageHeight, width: imageWidth),
                    if (null != imagePath)
                      const SizedBox(
                        height: 10,
                      ), // スペーサー

                    // ダイアログタイトル表示設定
                    _getTitleTextWidget(
                        titleStr: titleStr, titleColor: titleColor),
                    if (null != titleStr)
                      const SizedBox(
                        height: 20,
                      ), // Title が設定されているなら、スペース空ける

                    // ダイアログメッセージ本文表示設定
                    _getMsgTextWidget(msgStr: msgStr),
                    if (null != msgStr)
                      const SizedBox(
                        height: 30,
                      ), // 本文が設定されているなら、スペース空ける

                    //--- 以下ボタンエリア -----------------
                    Column(
                      children: <Widget>[
                        _getBtn(
                          // PositiveButton
                          btnStr: positiveBtnStr,
                          btnBgColor: themeProvider.currentTheme,
                          btnTextColor: COLOR_WHITE,
                          isCloseDialog: isPositiveCloseDialog,
                          onPressedCallback: onPositiveCallback,
                        ),
                        _getBtn(
                          // NegativeButton
                          btnStr: negativeBtnStr,
                          btnBgColor: secondButtonColor,
                          btnTextColor: COLOR_DLGBTN_ACCENT_NONE,
                          onPressedCallback: onNegativeCallback,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget showDialogWidget({
    @required Function onPositiveCallback,
    String msgStr,
    String titleStr,
    Color titleColor,
    String positiveBtnStr,
    String negativeBtnStr,
    bool isPositiveCloseDialog = true,
    Function onNegativeCallback,
  }) {
    final themeProvider =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    return Dialog(
      backgroundColor: theme.isLightTheme ? white : black,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(DIALOG_CORNER_ROUND), // Dialog自体の四隅角丸設定
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ), // スペーサー

                // ダイアログタイトル表示設定
                _getTitleTextWidget(titleStr: titleStr, titleColor: titleColor),
                if (null != titleStr)
                  const SizedBox(
                    height: 20,
                  ), // Title が設定されているなら、スペース空ける

                // ダイアログメッセージ本文表示設定
                _getMsgTextWidget(msgStr: msgStr),
                if (null != msgStr)
                  const SizedBox(
                    height: 30,
                  ), // 本文が設定されているなら、スペース空ける

                //--- 以下ボタンエリア -----------------
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _getBtn(
                        // PositiveButton
                        btnStr: positiveBtnStr,
                        btnBgColor: themeProvider.currentTheme,
                        btnTextColor: COLOR_WHITE,
                        isCloseDialog: isPositiveCloseDialog,
                        onPressedCallback: onPositiveCallback,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _getBtn(
                        // NegativeButton
                        btnStr: negativeBtnStr,
                        btnBgColor: secondButtonColor,
                        btnTextColor: COLOR_DLGBTN_ACCENT_NONE,
                        onPressedCallback: onNegativeCallback,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showWithdrawDialogWidget({
    @required Function onPositiveCallback,
    String msgStr,
    String titleStr,
    Color titleColor,
    String positiveBtnStr,
    String negativeBtnStr,
    bool isPositiveCloseDialog = true,
    Function onNegativeCallback,
  }) {
    final themeProvider =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    return Dialog(
      backgroundColor: theme.isLightTheme ? white : black,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(DIALOG_CORNER_ROUND), // Dialog自体の四隅角丸設定
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ), // スペーサー

                // ダイアログタイトル表示設定
                _getTitleTextWidget(titleStr: titleStr, titleColor: titleColor),
                if (null != titleStr)
                  const SizedBox(
                    height: 20,
                  ), // Title が設定されているなら、スペース空ける

                // ダイアログメッセージ本文表示設定
                _getMsgTextWidget(msgStr: msgStr),
                if (null != msgStr)
                  const SizedBox(
                    height: 30,
                  ), // 本文が設定されているなら、スペース空ける

                //--- 以下ボタンエリア -----------------
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _getBtn(
                        // PositiveButton
                        btnStr: positiveBtnStr,
                        btnBgColor: themeProvider.currentTheme,
                        btnTextColor: COLOR_WHITE,
                        isCloseDialog: isPositiveCloseDialog,
                        onPressedCallback: onPositiveCallback,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _getBtn(
                        // NegativeButton
                        btnStr: negativeBtnStr,
                        btnBgColor: secondButtonColor,
                        btnTextColor: COLOR_DLGBTN_ACCENT_NONE,
                        onPressedCallback: onNegativeCallback,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> showAppQuitConfirmDlg() async {
    if (Platform.isAndroid) {
      showYesNoDialog(
        titleStr: finishApplication,
        msgStr: confirmQuitApp,
        onPositiveCallback: () => SystemNavigator.pop(),
      );
    } else {
      showConfirmDialog(
        titleStr: cannotGoBackAnymore,
        msgStr: cannotGoBackAnymore,
      );
    }
    return true;
  }

  Future<T> showConfirmDialogSingleButton<T>({
    String msgStr,
    String titleStr,
    Color titleColor,
    String positiveBtnStr,
    String imagePath,
    double imageHeight = IMAGE_HEIGHT_DEFAULT,
    double imageWidth,
    VoidCallback onPressedPositiveButton,
  }) {
    imageWidth = imageWidth ?? imageHeight; // 幅指定なしの場合は、高さと同一
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final themeProvider =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);

    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: theme.isLightTheme ? white : black,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DIALOG_CORNER_ROUND), // Dialog自体の四隅角丸設定
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              // ダイアログ表示物のパディング値の設定
              horizontal: 30,
              vertical: 10,
            ),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ), // スペーサー

                    // 画像表示
                    getImageWidget(imagePath, imageHeight, width: imageWidth),
                    if (null != imagePath) const SizedBox(height: 10), // スペーサー
                    // ダイアログタイトル表示設定
                    _getTitleTextWidget(
                        titleStr: titleStr, titleColor: titleColor),
                    if (null != titleStr)
                      const SizedBox(height: 20), // Title が設定されているなら、スペース空ける
                    // ダイアログメッセージ本文表示設定
                    _getMsgTextWidget(msgStr: msgStr),
                    if (null != msgStr)
                      const SizedBox(height: 30), // 本文が設定されているなら、スペース空ける
                    //--- 以下ボタンエリア -----------------
                    Column(
                      children: <Widget>[
                        _getBtn(
                          // PositiveButton
                          btnStr: positiveBtnStr,
                          btnBgColor: themeProvider.currentTheme,
                          btnTextColor: white,
                          onPressed: onPressedPositiveButton,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showThreeButtonsDialog({
    @required Function onFirstCallback,
    String msgStr,
    String titleStr,
    Color titleColor,
    String imagePath,
    String imageUrl,
    double imageHeight = IMAGE_HEIGHT_DEFAULT,
    double imageWidth,
    String firstBtnStr,
    String secondBtnStr,
    String lastBtnStr,
    bool isPositiveCloseDialog = true,
    Function onSecondCallback,
    Function onLastCallback,
  }) {
    final themeProvider =
        Provider.of<SwitchAppThemeProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    // 以下未指定時のデフォルト設定
    firstBtnStr = firstBtnStr ?? 'はい'; // 肯定ボタン文字列
    secondBtnStr = secondBtnStr ?? cancel; // 否定ボタン文字列
    imageWidth = imageWidth ?? imageHeight; // 幅指定なしの場合は、高さと同一

    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: theme.isLightTheme ? white : black,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DIALOG_CORNER_ROUND), // Dialog自体の四隅角丸設定
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
            ),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ), // スペーサー

                      // ダイアログタイトル表示設定
                      _getTitleTextWidget(
                          titleStr: titleStr, titleColor: titleColor),
                      if (null != titleStr)
                        const SizedBox(
                          height: 10,
                        ), // Title が設定されているなら、スペース空ける

                      // ダイアログメッセージ本文表示設定
                      _getMsgTextWidget(msgStr: msgStr),
                      if (null != msgStr)
                        const SizedBox(
                          height: 10,
                        ), // 本文が設定されているなら、スペース空ける

                      //--- 以下ボタンエリア -----------------
                      Column(
                        children: <Widget>[
                          _getBtn(
                            // PositiveButton
                            btnStr: firstBtnStr,
                            btnBgColor: themeProvider.currentTheme,
                            btnTextColor: COLOR_WHITE,
                            isCloseDialog: isPositiveCloseDialog,
                            onPressedCallback: onFirstCallback,
                          ),
                          _getBtn(
                            // NegativeButton
                            btnStr: secondBtnStr,
                            btnBgColor: secondButtonColor,
                            btnTextColor: COLOR_DLGBTN_ACCENT_NONE,
                            onPressedCallback: onSecondCallback,
                          ),
                          _getBtn(
                            // NegativeButton
                            btnStr: lastBtnStr,
                            btnBgColor: secondButtonColor,
                            btnTextColor: COLOR_DLGBTN_ACCENT_NONE,
                            onPressedCallback: onLastCallback,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //========================================================================
  /// 以下共通部品系
  ///========================================================================

  /// タイトル表示Widget取得
  /// @param 	titleStr					: タイトル文字列
  /// @note		titleStrがnullの場合、空コンテナーを返却します → 何も表示されない（サイズも0となる）
  Widget _getTitleTextWidget({String titleStr, Color titleColor}) {
    if (null == titleStr) {
      return Container();
    }
    return Text(
      titleStr, // タイトル文字列
      textAlign: TextAlign.center, // 中央折返し
      style: TextStyle(
        color: titleColor ?? headerColor, // 文字色 : ピンク系
        fontSize: FONTSIZE_DLG_TITLE,
        fontWeight: FONTWEIGHT_DLG_TITLE,
//			fontFamily: "Roboto",
      ),
    );
  }

  /// ダイアログメッセージ表示Widget取得
  /// @param 	msgStr					: タイトル文字列
  /// @note		msgStr がnullの場合、空コンテナーを返却します → 何も表示されない（サイズも0となる）
  Widget _getMsgTextWidget({String msgStr}) {
    if (null == msgStr) {
      return Container();
    }
    return Text(
      msgStr, // ダイアログメッセージ文字列
      textAlign: TextAlign.center, // 中央折返し
      style: const TextStyle(
        fontSize: FONTSIZE_DLG_MSG,
        fontWeight: FONTWEIGHT_DLG_MSG,
        color: COLOR_TEXT_TONEDOWN,
      ),
    );
  }

  /// ボタンオブジェクト作成処理
  /// 文言がnull（指定なし）の場合は、表示ボタン無しとして、空コンテナオブジェクト（表示なし）を返却します。
  Widget _getBtn({
    String btnStr, // ボタン文字列
    Color btnBgColor, // ボタン背景色
    Color btnTextColor, // ボタンText色
    bool isCloseDialog = true, // ボタン押下でダイアログを閉じるか？
    VoidCallback onPressed,
    Function onPressedCallback, // ボタン押下時callback
  }) {
    if (null == btnStr || btnStr.isEmpty) {
      /// 表示しない場合
      return Container(); // 空コンテナを返却する
    } else {
      return Container(
        // ボタンの幅を大きくしたい → RaisedButton自体にwidthはないので、コンテナーを大きくとってやる
        width: double.infinity,
        child: FlatButton(
          // FlatButtonのほうが良さそう （RaisedButton より）
          // ボタン押下時処理
          onPressed: onPressed ??
              () {
                // ボタン押下でダイアログを閉じたくない場合を考慮 例）垢Banダイアログ等でHelp画面遷移
                if (isCloseDialog) {
                  /// 20200515 rootNavigator を指定しないと、直近のスタックがPopされてしまう問題対応
//                  Navigator.of(context).pop(); // ダイアログ閉じる
                  Navigator.of(context, rootNavigator: true).pop(); // ダイアログ閉じる
                }
                if (null != onPressedCallback) {
                  // callbackが指定されているなら実行
                  // ignore: prefer_if_null_operators
                  onPressedCallback();
                }
              },
          child: Text(
            btnStr, // ボタン文言
            style: TextStyle(
//						fontFamily: "Roboto",											// FontTypeを指定するならここ
              color: btnTextColor, // ボタン文言文字色
            ),
          ),
          color: btnBgColor, // ボタン背景色
          shape: const StadiumBorder(), // 角丸ボタン
        ),
      );
    }
  }

  /// ダイアログボタン作成メソッド
  /// @param 	btnInfList		: ダイアログボタン情報リスト
  /// @note		ボタン情報リスト分のボタンを作成します。
  List<Widget> getBtnWidgets(List<DialogBtnInfo> btnInfList) {
    final List<Widget> retWidgetList = <Widget>[];

    // パラメータ設定分のボタンをまるっと作成
    for (final DialogBtnInfo btn in btnInfList) {
      retWidgetList.add(_getBtn(
        btnStr: btn.title, // ボタン文字列
        btnBgColor: BTN_BG_COLORS[btn.btnStyle][0], // ボタン背景色
        btnTextColor: BTN_BG_COLORS[btn.btnStyle][1], // ボタン文字色
        onPressedCallback: btn.onPressCallback, // ボタン押下時処理
      ));
    }
    return retWidgetList;
  }

  /// 画像設定メソッド
  /// @param  assetsPath  : 画像パス（Assetsにあることを前提としてます）
  /// @param  height      : 画像高さ （必須）
  /// @param  width       : 画像幅 （未指定の場合は高さと等しくします : 正方形）
  Widget getImageWidget(String assetsPath, double height, {double width}) {
    if (null == assetsPath || assetsPath.isEmpty) {
      return Container(); // 画像指定なしの場合は空コンテナを返却
    } else {
      return Container(
        height: height,
        width: (width != null) ? width : height,
        child: Image.asset(assetsPath),
      );
    }
  }
}

enum eDialogBtnStyle {
  ACCENT_STRONG, // 通常のPositiveボタン配色
  ACCENT_WEAK, // 複数ボタン時の、ちょっと淡め配色
  ACCENT_NONE, // 指定なし。縁取りなし（Textのようなボタンになる）
}

const Map<eDialogBtnStyle, List<Color>> BTN_BG_COLORS =
    <eDialogBtnStyle, List<Color>>{
  eDialogBtnStyle.ACCENT_STRONG: <Color>[
    COLOR_DLGBTN_ACCENT_STRONG, // ボタン背景色
    COLOR_WHITE // 文字色
  ],
  eDialogBtnStyle.ACCENT_WEAK: <Color>[
    COLOR_DLGBTN_ACCENT_WEAK,
    COLOR_DLGBTN_ACCENT_STRONG
  ],
  eDialogBtnStyle.ACCENT_NONE: <Color>[null, COLOR_DLGBTN_ACCENT_NONE],
};

/// ダイアログボタン情報クラス
///
class DialogBtnInfo {
  /// コンストラクタ
  /// @param		title						: ボタン文字列
  /// @param		btnStyle				: ボタン背景色
  /// @param		onPressCallback	: ボタン文字列色
  DialogBtnInfo({
    @required this.title,
    @required this.btnStyle,
    this.onPressCallback,
  });

  final String title; // ダイアログボタン表示文字列
  final eDialogBtnStyle btnStyle; // ボタンスタイル
  final Function onPressCallback; // ボタン押下時処理（不要な場合は未指定 or null指定）
}
