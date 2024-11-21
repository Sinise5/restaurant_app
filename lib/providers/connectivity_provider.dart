import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  //late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late final StreamSubscription _connectivitySubscription;

  bool hasInternet = true;

  ConnectivityProvider() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    // Mendapatkan status koneksi awal
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Mendengarkan perubahan status koneksi
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(dynamic result) {
    if (result is List<ConnectivityResult> &&
        result.contains(ConnectivityResult.none)) {
      print("Tidak Tersambung ke WiFi");
      hasInternet = false;
    } else {
      print("tersambung ke WiFi");
      hasInternet = true;
    }

    // Periksa jika salah satu koneksi ada, maka ada internet
    //hasInternet = result is List<ConnectivityResult> && result.isNotEmpty;
    //notifyListeners();

    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
