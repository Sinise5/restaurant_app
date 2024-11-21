import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/connectivity_provider.dart';
import 'package:restaurant_app/providers/database_provider.dart';
import 'package:restaurant_app/providers/home_provider.dart';
import 'package:restaurant_app/providers/login_provider.dart';
import 'package:restaurant_app/providers/notification_provider.dart';
import 'package:restaurant_app/providers/restaurant_lite_provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/screens/home_screen.dart';
import 'package:restaurant_app/screens/login_screen.dart';
import 'package:restaurant_app/screens/restaurant_det_screen.dart';
import 'package:restaurant_app/screens/restaurant_fav_screen.dart';
import 'package:restaurant_app/screens/restaurant_screen.dart';
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseProvider().database;
  ApiService apiService = ApiService();
  Workmanager().initialize(NotificationService.callbackDispatcher);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => HomeNotifier()),
        ChangeNotifierProvider(create: (_) => LoginState()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantLiteProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Splash Screen',
      theme: themeProvider.currentTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/home': (context) => const HomePage(),
        '/restoran': (context) => const RestoranApi(),
        '/restorandet': (context) => const RestorandetApi(
              restaurantId: '',
            ),
        '/restoran_fav': (context) => const RestoranFav(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
