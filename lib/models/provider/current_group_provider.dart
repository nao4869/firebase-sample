import 'package:flutter/material.dart';

class CurrentGroupProvider with ChangeNotifier {
  CurrentGroupProvider({
    this.groupId,
  });

  String groupId;

  void updateGroupId(String newgGroupId) {
    groupId = newgGroupId;
  }
}
