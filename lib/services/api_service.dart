import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:restaurant_app/models/restoran_api.dart';
import 'package:restaurant_app/models/restorandet_api.dart';

class ApiService {
  final String baseUrl = 'https://restaurant-api.dicoding.dev';

  Future<List<RestoranApiM>>? fetchRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final restaurantsList = data['restaurants'] as List;
      return restaurantsList
          .map((json) => RestoranApiM.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<RestoranDetApiM>? fetchRestaurantDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/detail/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RestoranDetApiM.fromJson(data['restaurant']);
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }

  Future<RestoranDetApiM>? fetchRestaurantDetailsList(String id) async {
    final response = await http
        .get(Uri.parse('https://restaurant-api.dicoding.dev/detail/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Mengembalikan List, bukan satu objek
      return
        RestoranDetApiM.fromJson(data['restaurant'])
      ; // Menjadikan list jika perlu
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }

  Future<List<RestoranApiM>>? searchRestaurants(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['restaurants'] as List)
          .map((json) => RestoranApiM.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
