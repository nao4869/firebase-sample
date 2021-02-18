import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sample/models/provider/current_group_provider.dart';
import 'package:firebase_sample/models/screen_size/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_sample/extensions/set_image_path.dart';

class TaggedUserImage extends StatelessWidget {
  const TaggedUserImage({
    @required this.taggedUserReferenceId,
    @required this.sizeType,
  });

  final String taggedUserReferenceId;
  final ScreenSizeType sizeType;

  @override
  Widget build(BuildContext context) {
    final groupNotifier = Provider.of<CurrentGroupProvider>(context);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('versions')
          .doc('v1')
          .collection('groups')
          .doc(groupNotifier.groupId)
          .collection('users')
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> userSnapShot) {
        if (userSnapShot.hasError || !userSnapShot.hasData) {
          return SizedBox(height: 35);
        } else if (userSnapShot.hasData && userSnapShot.data.size != 0) {
          DocumentSnapshot currentTaggedUserSnapShot = userSnapShot?.data?.docs
              ?.firstWhere((user) => user.id == taggedUserReferenceId,
                  orElse: null);
          final imageWidget =
              setImagePath(currentTaggedUserSnapShot['imagePath']);
          return SizedBox(
            height: sizeType == ScreenSizeType.large ? 30 : 45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: imageWidget,
            ),
          );
        } else {
          return SizedBox(height: 35);
        }
      },
    );
  }
}
