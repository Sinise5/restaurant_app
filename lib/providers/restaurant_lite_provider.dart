import 'package:flutter/material.dart';
import 'package:restaurant_app/models/restaurant_lite.dart';
import 'package:restaurant_app/providers/database_provider.dart';

class RestaurantLiteProvider with ChangeNotifier {
  List<Restaurant> _restaurants_lite = [];

  List<Restaurant> get restaurants => _restaurants_lite;

  Future<void> addRestaurant(Restaurant restaurant) async {
    await DatabaseProvider.instance.insertRestaurant(restaurant);
    _restaurants_lite.add(restaurant);
    notifyListeners();
  }

  Future<void> fetchRestaurant(String id) async {
    final restaurant = await DatabaseProvider.instance.getRestaurant(id);
    if (restaurant != null) {
      _restaurants_lite = [restaurant];
      notifyListeners();
    }
  }

  Future<void> deleteRestaurant(String id) async {
    await DatabaseProvider.instance.deleteRestaurant(id);
    _restaurants_lite.removeWhere((restaurant) => restaurant.id == id);
    notifyListeners();
  }

  Future<bool> isRestaurantSaved(String id) async {
    return await DatabaseProvider.isRestaurantExist(id);
  }
}
