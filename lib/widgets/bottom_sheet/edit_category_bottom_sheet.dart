import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
import 'package:firebase_sample/widgets/bottom_sheet_content/date_row.dart';
import 'package:firebase_sample/widgets/buttons/full_width_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_sample/extensions/set_image_path.dart';

class EditCategoryBottomSheet extends StatelessWidget {
  EditCategoryBottomSheet({
    this.buttonTitle,
    this.initialValue,
    this.selectedRemindDate,
    this.selectedPersonId,
    this.onUpdatePressed,
    this.showDateTimePicker,
    this.onSelectedPersonChanged,
    this.onNameChange,
  });

  final String buttonTitle;
  final String initialValue;
  final String selectedPersonId;
  final DateTime selectedRemindDate;
  final VoidCallback onUpdatePressed;
  final VoidCallback showDateTimePicker;
  final VoidCallback onSelectedPersonChanged;
  final Function(String) onNameChange;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
    final groupNotifier = Provider.of<CurrentGroupProvider>(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: size.width * .2,
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
                child: TextFormField(
                  maxLines: 20,
                  autofocus: true,
                  onChanged: onNameChange,
                  initialValue: initialValue,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          DateRow(
            remindDate: selectedRemindDate,
            onPressed: showDateTimePicker,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('versions')
                .doc('v1')
                .collection('groups')
                .doc(groupNotifier.groupId)
                .collection('users')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // エラーの場合
              if (snapshot.hasError || snapshot.data == null) {
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    switchAppThemeNotifier.currentTheme,
                  ),
                );
              } else {
                return SizedBox(
                  height: 40,
                  width: size.width * .9,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        'Who\'s task?',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(width: 10);
                        },
                        itemCount: snapshot.data.size,
                        itemBuilder: (BuildContext context, int index) {
                          final imageWidget = setImagePath(
                              snapshot.data.docs[index].data()['imagePath']);
                          return InkWell(
                            onTap: onSelectedPersonChanged,
                            child: SizedBox(
                              height: 30,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Stack(
                                  children: [
                                    imageWidget,
                                    if (selectedPersonId ==
                                        snapshot.data.docs[index].id)
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: switchAppThemeNotifier
                                                .currentTheme
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            width: size.width,
            child: FullWidthButton(
              title: buttonTitle,
              onPressed: onUpdatePressed,
            ),
          ),
        ],
      ),
    );
  }
}
