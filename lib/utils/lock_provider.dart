import 'package:flutter/material.dart';

class LockProvider with ChangeNotifier {
  bool _isLocked = false; // Default state

  bool get isLocked => _isLocked;

  void toggleLock() {
    _isLocked = !_isLocked;
    notifyListeners(); // Notify all listening widgets
  }
}
