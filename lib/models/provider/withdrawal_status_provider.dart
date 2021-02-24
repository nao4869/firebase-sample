import 'package:flutter/material.dart';

class WithdrawalStatusProvider with ChangeNotifier {
  WithdrawalStatusProvider({
    this.isWithdrawn = false,
  });

  bool isWithdrawn;

  void updateWithdrawalStatus(bool newStatus) {
    this.isWithdrawn = newStatus;
    notifyListeners();
  }
}
