import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/login_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/screens/home_screen.dart';
import 'package:restaurant_app/widgets/slide_anim.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<void> _login(
      BuildContext context, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (email == 'test@example.com' && password == 'password123') {
      try {
        prefs.setString("Login", '1');
        prefs.setString("email", email);
        Navigator.pushReplacement(
          context,
          SlideRightRoute(page: const HomePage()),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
        throw Exception("Error occurred while setting user preferences: $e");
      }
    } else {
      prefs.setString("Login", '0');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau password salah')),
      );
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Under Development!')),
    );
  }

  void _loginWithTwitter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Under Development!')),
    );
  }

  void _loginWithFacebook(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Under Development!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final loginState = Provider.of<LoginState>(context);

    return Scaffold(
      backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: screenHeight * 0.1,
          bottom: screenHeight * 0.05,
        ),
        child: Form(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/sinise3.png', // Ganti dengan path gambar Anda
                        width: screenWidth * 0.3, // Sesuaikan ukuran
                        height: screenWidth * 0.3, // Sesuaikan ukuran
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Welcome Back Sinise!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Login to your account to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: themeProvider.currentTheme.iconTheme.color,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    obscureText: !loginState.isPasswordVisible,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: themeProvider.currentTheme.iconTheme.color,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          loginState.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          loginState.togglePasswordVisibility();
                        },
                        color: themeProvider.currentTheme.iconTheme.color,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      // Replace with the email and password values as needed
                      _login(context, email, password);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Or sign in with',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          _loginWithGoogle(context);
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                          size: screenWidth * 0.08,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      IconButton(
                        onPressed: () {
                          _loginWithTwitter(context);
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.twitter,
                          color: Colors.blueAccent,
                          size: screenWidth * 0.08,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      IconButton(
                        onPressed: () {
                          _loginWithFacebook(context);
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.facebook,
                          color: Colors.blue,
                          size: screenWidth * 0.08,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
