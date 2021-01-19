import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/constants/colors.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/pages/home/add_new_category_screen_notifier.dart';
import 'package:firebase_sample/widgets/text_form/text_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_sample/app_localizations.dart';
import 'package:firebase_sample/models/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen();

  static String routeName = 'category-photo-screen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddCategoryScreenNotifier(
        context: context,
        switchAppThemeNotifier: Provider.of(context, listen: false),
      ),
      child: _CategoryPhotoScreen(),
    );
  }
}

class _CategoryPhotoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier =
        Provider.of<AddCategoryScreenNotifier>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final darkModeNotifier = Provider.of<ThemeProvider>(context);
    final groupNotifier =
        Provider.of<CurrentGroupProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.isLightTheme ? themeColor : darkBlack,
      appBar: AppBar(
        backgroundColor: notifier.switchAppThemeNotifier.currentTheme,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: white,
          ),
          color: notifier.switchAppThemeNotifier.currentTheme,
          iconSize: 30.0,
          onPressed: notifier.pop,
        ),
        title: Text(
          'Manage Category',
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: notifier.openModalBottomSheet,
              child: Icon(
                Icons.add,
                color: white,
                size: 30.0,
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('versions')
            .doc('v1')
            .collection('groups')
            .doc(groupNotifier.groupId)
            .collection('categories')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // エラーの場合
          if (snapshot.hasError || snapshot.data == null) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                notifier.switchAppThemeNotifier.currentTheme,
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          notifier.displayActionSheet(
                            collection: 'categories',
                            documentId: snapshot.data.docs[index].id,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: size.width * .8,
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.isLightTheme ? white : black,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: colorList[index],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: size.width * .6,
                                    height: size.width * .6,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        snapshot.data.docs[index]
                                            .data()['name'],
                                        style: TextStyle(
                                          color: darkModeNotifier.isLightTheme
                                              ? black
                                              : white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// タスク追加時の表示ダイアログ
  /// ダイアログ内のみでState更新の為、setStateを引数に渡す
  Widget buildAddTaskDialog(
    BuildContext context,
    Function setState,
  ) {
    final size = MediaQuery.of(context).size;
    final notifier =
        Provider.of<AddCategoryScreenNotifier>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    return SizedBox(
      height: 300,
      child: SimpleDialog(
        backgroundColor: theme.isLightTheme ? white : black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        children: <Widget>[
          SimpleDialogOption(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('selectCategoryColor'),
                      style: TextStyle(
                        color: notifier.switchAppThemeNotifier.currentTheme,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: size.width * .7,
                  width: size.width * .5,
                  child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                    ),
                    itemCount: colorList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              notifier.onSelectedColorChange(index);
                              setState(() {});
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: ColoredBox(
                                color: colorList[index],
                              ),
                            ),
                          ),
                          notifier.selectedColorIndex == index
                              ? Positioned(
                                  top: 3,
                                  right: 15,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 15.0,
                                  ),
                                )
                              : Container(),
                        ],
                      );
                    },
                  ),
                ),
                buildRaisedButton(
                  context,
                  title: AppLocalizations.of(context).translate('add'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    notifier.addCategory();
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // カテゴリー名追加時の表示ダイアログ
  Widget buildAddCategoryNameDialog(
    BuildContext context,
  ) {
    final notifier =
        Provider.of<AddCategoryScreenNotifier>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    return SimpleDialog(
      backgroundColor: theme.isLightTheme ? white : black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(32.0),
        ),
      ),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: Column(
            children: [
              CustomTextFormField(
                formKey: notifier.nameFieldFormKey,
                height: 80,
                onChanged: notifier.onNameChange,
                controller: notifier.textController,
                resetTextField: notifier.resetNameTextField,
                hintText:
                    AppLocalizations.of(context).translate('imageCategory'),
//                initialValue: selectedCategory.name,
//                isDisplayUnderLine: true,
              ),
              const SizedBox(height: 10),
              buildRaisedButton(
                context,
                title: AppLocalizations.of(context).translate('decide'),
                onPressed: () {
                  Navigator.of(context).pop();
                  //notifier.addCategoryName(selectedCategory);
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  /// タスク追加時、編集時に表示するボタン
  Widget buildRaisedButton(
    BuildContext context, {
    @required String title,
    @required VoidCallback onPressed,
  }) {
    final notifier =
        Provider.of<AddCategoryScreenNotifier>(context, listen: false);
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        color: notifier.switchAppThemeNotifier.currentTheme,
        elevation: 0,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
