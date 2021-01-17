import 'package:flutter/material.dart';

class UserReferenceProvider with ChangeNotifier {
  UserReferenceProvider({
    this.referenceToUser,
  });

  String referenceToUser;

  void updateUserReference(String newUserReference) {
    referenceToUser = newUserReference;
  }
}
