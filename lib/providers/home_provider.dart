import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/login_screen.dart';
import 'package:restaurant_app/widgets/slide_anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeNotifier with ChangeNotifier {
  String _dataEmail = '-';
  final bool _isButtonVisible = true;

  String get dataEmail => _dataEmail;
  bool get isButtonVisible => _isButtonVisible;

  void setEmail(String email) {
    _dataEmail = email;
    notifyListeners();
  }

  Future<void> cekLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String login = prefs.getString("Login") ?? "0";
    String email = prefs.getString("email") ?? "";

    if (login == '0') {
      Navigator.pushReplacement(context, SlideRightRoute(page: LoginPage()));
    } else {
      setEmail(email);
    }
  }
}
