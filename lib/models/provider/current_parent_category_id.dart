import 'package:flutter/material.dart';

class CurrentParentCategoryIdProvider with ChangeNotifier {
  CurrentParentCategoryIdProvider({
    this.currentParentCategoryId,
  });

  String currentParentCategoryId;

  void updateCurrentParentCategoryId(String newId) {
    currentParentCategoryId = newId;
    notifyListeners();
  }
}
