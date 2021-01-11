import 'package:flutter/material.dart';

class CurrentGroupProvider with ChangeNotifier {
  CurrentGroupProvider({
    this.groupId,
  });

  String groupId;
}
