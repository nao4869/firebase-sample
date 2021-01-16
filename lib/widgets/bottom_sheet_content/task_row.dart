//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_sample/models/provider/current_group_provider.dart';
//import 'package:firebase_sample/models/provider/switch_app_theme_provider.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//
//class TaskRow extends StatelessWidget {
//  TaskRow({
//    this.title,
//    this.selectedPersonIndex,
//  });
//
//  final String title;
//  final int selectedPersonIndex;
//
//  @override
//  Widget build(BuildContext context) {
//    final size = MediaQuery.of(context).size;
//    final groupNotifier =
//        Provider.of<CurrentGroupProvider>(context, listen: false);
//    final switchAppThemeNotifier = Provider.of<SwitchAppThemeProvider>(context);
//    return StreamBuilder(
//      stream: FirebaseFirestore.instance
//          .collection('groups')
//          .doc(groupNotifier.groupId)
//          .collection('users')
//          .snapshots(),
//      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//        // エラーの場合
//        if (snapshot.hasError || snapshot.data == null) {
//          return CircularProgressIndicator(
//            valueColor: AlwaysStoppedAnimation<Color>(
//              switchAppThemeNotifier.currentTheme,
//            ),
//          );
//        } else {
//          return SizedBox(
//            height: 40,
//            width: size.width * .9,
//            child: Row(
//              children: [
//                const SizedBox(width: 20),
//                Text(
//                  title,
//                  style: TextStyle(
//                    fontSize: 15.0,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//                const SizedBox(width: 10),
//                ListView.separated(
//                  shrinkWrap: true,
//                  scrollDirection: Axis.horizontal,
//                  separatorBuilder: (BuildContext context, int index) {
//                    return const SizedBox(width: 10);
//                  },
//                  itemCount: snapshot.data.size,
//                  itemBuilder: (BuildContext context, int index) {
//                    return InkWell(
//                      onTap: () {
//                        selectedPersonIndex = index;
//                      },
//                      child: SizedBox(
//                        height: 30,
//                        child: ClipRRect(
//                          borderRadius: BorderRadius.circular(30),
//                          child: Stack(
//                            children: [
//                              Image.asset(
//                                'assets/images/default_profile_image.png',
//                              ),
//                              if (selectedPersonIndex == index)
//                                SizedBox(
//                                  height: 40,
//                                  width: 40,
//                                  child: DecoratedBox(
//                                    decoration: BoxDecoration(
//                                      borderRadius: BorderRadius.circular(30),
//                                      color: switchAppThemeNotifier.currentTheme
//                                          .withOpacity(0.5),
//                                    ),
//                                  ),
//                                ),
//                            ],
//                          ),
//                        ),
//                      ),
//                    );
//                  },
//                ),
//              ],
//            ),
//          );
//        }
//      },
//    );
//  }
//}
