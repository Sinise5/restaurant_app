import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restaurant_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class myDialog00 {
  _confirmResult0(BuildContext context, bool isYes, String untuk) async {
    if (!isYes) {
      Navigator.of(context).pop();
    } else {
      if (untuk == "logot") {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        _googleSignIn.disconnect();
        prefs.setString("Login", '0');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
      }
    }
  }

  confirm0(BuildContext context, String judul, String isi, String untuk) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(judul),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(isi)],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () => _confirmResult0(context, false, untuk),
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => _confirmResult0(context, true, untuk),
              ),
            ],
          );
        });
  }
}
