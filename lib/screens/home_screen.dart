import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/home_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/screens/restaurant_fav_screen.dart';
import 'package:restaurant_app/screens/restaurant_screen.dart';
import 'package:restaurant_app/screens/setting_screen.dart';
import 'package:restaurant_app/widgets/custom_card.dart';
import 'package:restaurant_app/widgets/dialog.dart';
import 'package:restaurant_app/widgets/slide_anim.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  String dataEmail = '-';
  bool isButtonVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //ceklogin();
    Provider.of<HomeNotifier>(context, listen: false).cekLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final homeProvider = Provider.of<HomeNotifier>(context);

    Widget head00 = Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset("assets/sinise3.png", height: 45),
          const Text(
            "SINISE",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkTheme
                ? Icons.light_mode_outlined
                : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );

    Widget wLogotbutton = Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              homeProvider.dataEmail,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Visibility(
              visible: isButtonVisible,
              child: ElevatedButton(
                onPressed: () {
                  myDialog00().confirm0(
                    context,
                    "Konfirmasi",
                    "Apakah Anda Akan Logout?",
                    "logot",
                  );
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(const Color(0xFFDA7272)),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text("Logout",
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await refreshList0();
        },
        child: Stack(
          children: [
            ListView(children: [
              head00,
              wLogotbutton,
              const SizedBox(height: 15),
              CustomCard(Icons.list, "Restourant API", "List Restourant", () {
                Navigator.push(
                    context, SlideRightRoute(page: const RestoranApi()));
              }, true, 0),
              const SizedBox(height: 15),
              CustomCard(
                  Icons.list, "Restourant Favorit", "List Restourant Favorit",
                  () {
                Navigator.push(
                    context, SlideRightRoute(page: const RestoranFav()));
              }, true, 0),
              const SizedBox(height: 15),
              CustomCard(Icons.list, "Setting Notification", "Notification",
                  () {
                Navigator.push(context, SlideRightRoute(page: const SettingsPage()));
              }, true, 0),
            ]),
          ],
        ),
      ),
    );
  }

  Future<Null> refreshList0() async {
    await Future.delayed(const Duration(seconds: 2));

    return null;
  }
}
