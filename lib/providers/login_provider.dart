import 'package:flutter/material.dart';

class LoginState with ChangeNotifier {
  bool _isPasswordVisible = false;
  final bool _isGoogel = false;

  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
}
