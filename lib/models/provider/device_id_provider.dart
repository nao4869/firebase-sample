import 'package:flutter/material.dart';

class DeviceIdProvider with ChangeNotifier {
  DeviceIdProvider({
    this.androidUid,
    this.iosUid,
  });

  final String androidUid;
  final String iosUid;
}
