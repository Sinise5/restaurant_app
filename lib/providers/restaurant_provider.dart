import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/restaurant_lite.dart';
import 'package:restaurant_app/models/restoran_api.dart';
import 'package:restaurant_app/models/restorandet_api.dart';
import 'package:restaurant_app/providers/connectivity_provider.dart';
import 'package:restaurant_app/providers/database_provider.dart';
import 'package:restaurant_app/providers/restaurant_lite_provider.dart';
import 'package:restaurant_app/services/api_service.dart';

enum ResultState { loading, success, error, idle, hasData, noData }

class RestaurantProvider with ChangeNotifier {
  ResultState _state = ResultState.idle;
  final ApiService apiService;

  RestaurantProvider({required this.apiService, ResultState? initialState}) {
    if (initialState != null) {
      _state = initialState;
    }
  }

  ResultState get state => _state;

  List<RestoranApiM> _restaurants = [];
  List<RestoranApiM> _filteredRestaurants = [];

  String _errorMessage = '';
  bool _isLoading = false;
  String _searchQuery = '';
  bool _errorInternet = false;
  bool _notfound = false;
  bool _isFetching = false;
  bool _isFavorite = false;

  RestoranDetApiM? _restaurant;
  Map<String, dynamic>? _dataJsonRestaurants;

  List<RestoranApiM> get restaurants =>
      _filteredRestaurants.isNotEmpty ? _filteredRestaurants : _restaurants;
  String get errorMessage => _errorMessage;
  String get message => _errorMessage;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  RestoranDetApiM? get restaurant => _restaurant;
  bool get errorInternet => _errorInternet;
  bool get notfound => _notfound;
  Map<String, dynamic>? get restaurants_data_json => _dataJsonRestaurants;
  bool get isFavorite => _isFavorite;

  void toggleFavorite(
      BuildContext context, Map<String, dynamic>? restaurantsDataJson) async {
    _isFavorite = !_isFavorite;
    Map<String, dynamic>? data = restaurantsDataJson;
    String id = data?['id'];

    if (_isFavorite) {
      saveRestaurantSqlite(id, data, context);
    } else {
      removeRestaurantSqlite(id, context);
    }
    checkRestaurantFavorite(context, id);

    notifyListeners();
  }

  void saveRestaurantSqlite(
      String? id, Map<String, dynamic>? jsonDet, BuildContext context) {
    if (id == null || jsonDet == null) return;

    final jsonData = json.encode(jsonDet);

    final restaurant = Restaurant(
      id: id,
      jsonData: jsonData,
      timeAdded: DateTime.now().toIso8601String(),
    );

    // Gunakan Provider untuk menambah data ke SQLite
    context.read<RestaurantLiteProvider>().addRestaurant(restaurant);
  }

  void removeRestaurantSqlite(String id, BuildContext context) {
    context.read<RestaurantLiteProvider>().deleteRestaurant(id);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error,
      {bool errorInternet = false, bool notfound = false}) {
    if (!_isFetching) {
      _isFetching = true;

      _errorMessage = error;
      _errorInternet = errorInternet;
      _notfound = notfound;
      _isFetching = false;
      notifyListeners();
    }
  }

  void setState(ResultState state) {
    _state = state;
    notifyListeners();
  }

  Future<bool> fetchRestaurants_error({bool refresh = true}) async {

    if (!refresh && _restaurants.isNotEmpty) return true;


    setState(ResultState.loading);
    _setLoading(true);
    _errorMessage = '';
    _setError('');

    try {
      final response =
      await http.get(Uri.parse('https://restaurant-api.dicoding.devx/list'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final restaurantsList = data['restaurants'] as List<dynamic>;

        _restaurants =
            restaurantsList.map((json) => RestoranApiM.fromJson(json)).toList();


        if (_restaurants.isEmpty) {

          _setError('No restaurants available.', errorInternet: false, notfound: true);
          setState(ResultState.noData);
          return false;
        } else {
          _filteredRestaurants = _restaurants;
          setState(ResultState.hasData);
          return true;
        }

      } else {

        _setError('Failed to load restaurants', errorInternet: false, notfound: true);

        setState(ResultState.error);
        return false;
      }
    } on SocketException catch (e) {

      clearSearch();
      if (e.osError?.errorCode == 7) {
        _setError('Cannot connect to server. Please check your internet connection.',
            errorInternet: true);
      } else {
        _setError('Failed to load data', errorInternet: true);
      }
      setState(ResultState.error);
      return false;
    } catch (e) {
      // Tangani error lain yang tidak terduga.
      _setError('Failed to load data', errorInternet: false, notfound: true);
      setState(ResultState.error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> fetchRestaurants({bool refresh = true}) async {

    if (!refresh && _restaurants.isNotEmpty) return true;


    setState(ResultState.loading);
    _setLoading(true);
    _errorMessage = '';
    _setError('');

    try {
      final response =
      await http.get(Uri.parse('https://restaurant-api.dicoding.dev/list'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final restaurantsList = data['restaurants'] as List<dynamic>;

        _restaurants =
            restaurantsList.map((json) => RestoranApiM.fromJson(json)).toList();


        if (_restaurants.isEmpty) {

          _setError('No restaurants available.', errorInternet: false, notfound: true);
          setState(ResultState.noData);
          return false;
        } else {
          _filteredRestaurants = _restaurants;
          setState(ResultState.hasData);
          return true;
        }

      } else {

        _setError('Failed to load restaurants', errorInternet: false, notfound: true);

        setState(ResultState.error);
        return false;
      }
    } on SocketException catch (e) {

      clearSearch();
      if (e.osError?.errorCode == 7) {
        _setError('Cannot connect to server. Please check your internet connection.',
            errorInternet: true);
      } else {
        _setError('Failed to load data.', errorInternet: true);
      }
      setState(ResultState.error);
      return false;
    } catch (e) {
      // Tangani error lain yang tidak terduga.
      _setError('Failed to load data', errorInternet: false, notfound: true);
      setState(ResultState.error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void searchRestaurants(String query) {
    _searchQuery = query;
    _filteredRestaurants = query.isEmpty
        ? _restaurants
        : _restaurants
            .where((restaurant) =>
                restaurant.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    notifyListeners();
  }

  void clearSearch() {
    _filteredRestaurants = _restaurants;
    _searchQuery = '';
    notifyListeners();
  }

  void clearData() {
    _filteredRestaurants = [];
    _searchQuery = '';
    notifyListeners();
  }

  void _resetData() {
    _restaurant = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> fetchRestaurantDetails(String id) async {
    _resetData();
    final connectivityResult = await Connectivity().checkConnectivity();
    _setError('');
    setState(ResultState.loading);
    //debugPrint('provider {$id} detail $connectivityResult');
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _setError('No internet connection. Please try again later.',
          errorInternet: true, notfound: false);
    } else {
      _setLoading(true);
      final url = 'https://restaurant-api.dicoding.dev/detail/$id';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['error'] == false) {
            _restaurant = RestoranDetApiM.fromJson(data['restaurant']);
            _dataJsonRestaurants = _restaurant?.toJson();
            setState(ResultState.success);
          } else {
            _setError(data['message'], errorInternet: false, notfound: true);
          }
        } else {
          _setError('Failed to load restaurant data',
              errorInternet: false, notfound: true);
        }
      } on SocketException catch (e) {
        if (e.osError?.errorCode == 7) {
          _setError(
              'Cannot connect to server. Please check your internet connection.',
              errorInternet: true);
        } else {
          _setError('No internet connection.', errorInternet: true);
        }
        setState(ResultState.error);
      } catch (e) {
        _setError('Error: $e');
        setState(ResultState.error);
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<bool> fetchRestaurantDetailsTest(String id) async {
    _resetData();
    _setError('');
    setState(ResultState.loading);

      _setLoading(true);
      final url = 'https://restaurant-api.dicoding.dev/detail/$id';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['error'] == false) {
            _restaurant = RestoranDetApiM.fromJson(data['restaurant']);
            setState(ResultState.hasData);
            return true;
          } else {
            _setError(data['message'], errorInternet: false, notfound: true);
            setState(ResultState.noData);
            return false;
          }
        } else {
          _setError('Failed to load restaurant data',
              errorInternet: false, notfound: true);
          return false;
        }
      } on SocketException catch (e) {
        if (e.osError?.errorCode == 7) {
          _setError(
              'Cannot connect to server. Please check your internet connection.',
              errorInternet: true);
        } else {
          _setError('No internet connection.', errorInternet: true);
        }
        setState(ResultState.error);
        return false;
      } catch (e) {
        _setError('Error: $e');
        setState(ResultState.error);
        return false;
      } finally {
        _setLoading(false);
      }

  }

  Future<void> searchRestaurantsApi(String query) async {
    if (query.isEmpty) {
      await fetchRestaurants();
      return;
    }
    setState(ResultState.loading);
    _setError('');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _setError('No internet connection. Please try again later.',
          errorInternet: true, notfound: false);
      _restaurants = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _searchQuery = query;
    _errorMessage = '';

    try {
      final response = await http.get(
        Uri.parse('https://restaurant-api.dicoding.dev/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _restaurants = (data['restaurants'] as List)
            .map((restaurant) => RestoranApiM.fromJson(restaurant))
            .toList();
        _filteredRestaurants = _restaurants;

        setState(ResultState.hasData);
       // debugPrint(_restaurants.toString());
        if (_restaurants.isEmpty) {
          _setError('No restaurants found for your search.',
              errorInternet: false, notfound: true);
          setState(ResultState.noData);
        }
      } else {
        _setError('Failed to load search results',
            errorInternet: false, notfound: true);
        _restaurants = [];
      }
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 7) {
        _setError(
            'Cannot connect to server. Please check your internet connection.',
            errorInternet: true);
      } else {
        _setError('No internet connection.', errorInternet: true);
      }
      _restaurants = [];
      setState(ResultState.error);
    } catch (e) {
      _setError('Error: $e', errorInternet: false, notfound: true);
      _restaurants = [];
      setState(ResultState.error);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> searchRestaurantsApiTest(String query) async {
    if (query.isEmpty) {
      await fetchRestaurants();  // Pemanggilan fetchRestaurants jika query kosong
      return false;
    }

    setState(ResultState.loading);
    _setError('');

    _setLoading(true);
    _searchQuery = query;
    _errorMessage = '';

    try {
      final response = await http.get(
        Uri.parse('https://restaurant-api.dicoding.dev/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _restaurants = (data['restaurants'] as List)
            .map((restaurant) => RestoranApiM.fromJson(restaurant))
            .toList();


        setState(ResultState.hasData);
        if (_restaurants.isEmpty) {
          _setError('No restaurants found for your search.',
              errorInternet: false, notfound: true);
          setState(ResultState.noData);
          return false;
        } else {
          _filteredRestaurants = _restaurants;
          setState(ResultState.hasData);
          return true;
        }
      } else {
        _setError('Failed to load search results',
            errorInternet: false, notfound: true);
        _restaurants = [];
        return false;
      }
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 7) {
        _setError(
            'Cannot connect to server. Please check your internet connection.',
            errorInternet: true);
      } else {
        _setError('No internet connection.', errorInternet: true);
      }
      _restaurants = [];
      setState(ResultState.error);
      return false;
    } catch (e) {
      _setError('Error: $e', errorInternet: false, notfound: true);
      _restaurants = [];
      setState(ResultState.error);
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> searchRestaurantsApiTestError(String query) async {
    if (query.isEmpty) {
      await fetchRestaurants();  // Pemanggilan fetchRestaurants jika query kosong
      return false;
    }
    setState(ResultState.loading);
    _setError('');

    _setLoading(true);
    _searchQuery = query;
    _errorMessage = '';

    try {
      final response = await http.get(
        Uri.parse('https://restaurant-api.dicoding.devx/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _restaurants = (data['restaurants'] as List)
            .map((restaurant) => RestoranApiM.fromJson(restaurant))
            .toList();
        _filteredRestaurants = _restaurants;

        setState(ResultState.hasData);
        if (_restaurants.isEmpty) {
          _setError('No restaurants found for your search.',
              errorInternet: false, notfound: true);
          setState(ResultState.noData);
          return false;  // Mengembalikan false jika tidak ada restoran
        } else {
          return true;  // Mengembalikan true jika restoran ditemukan
        }
      } else {
        _setError('Failed to load search results',
            errorInternet: false, notfound: true);
        _restaurants = [];
        return false;
      }
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 7) {
        _setError(
            'Cannot connect to server. Please check your internet connection.',
            errorInternet: true);
      } else {
        _setError('Failed to load search results', errorInternet: true);
      }
      _restaurants = [];
      setState(ResultState.error);
      return false;
    } catch (e) {
      _setError('Error: $e', errorInternet: false, notfound: true);
      _restaurants = [];
      setState(ResultState.error);
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String restaurantId,
    required String name,
    required String review,
  }) async {
    const url = 'https://restaurant-api.dicoding.dev/review';
    final body = json.encode({
      "id": restaurantId,
      "name": name,
      "review": review,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          _restaurant?.customerReviews = (data['customerReviews'] as List)
              .map((e) => CustomerReview.fromJson(e))
              .toList();
          notifyListeners();
        }
      } else {
        _setError('Failed to submit review');
      }
    } catch (e) {
      _setError('Error: $e');
    }
  }

  void checkAndFetchData(BuildContext context) {
    if (Provider.of<ConnectivityProvider>(context, listen: false).hasInternet) {
      fetchRestaurants();
    } else {
      debugPrint('Tidak ada internet');
    }
  }

  Future<void> checkRestaurantFavorite(BuildContext context, String id) async {
    bool isSaved =
        await context.read<RestaurantLiteProvider>().isRestaurantSaved(id);

    if (isSaved) {
      _isFavorite = true;
      debugPrint('Restoran sudah ada di database');
    } else {
      _isFavorite = false;
      debugPrint('Restoran belum ada di database');
    }
  }

  Future<bool> fetchRestaurantsFavorite({bool refresh = true}) async {
    if (!refresh && _restaurants.isNotEmpty) return true;

    _setLoading(true);
    _errorMessage = '';
    _setError('');

    try {
      // Ambil data dari SQLite
      final restaurants = await DatabaseProvider.instance.getAllRestaurants();

      if (restaurants.isNotEmpty) {
        _restaurants = [];

        for (var restaurant in restaurants) {
          final jsonData =
              json.decode(restaurant.jsonData); // Mengonversi ke Map

          _restaurants.add(RestoranApiM.fromJson(jsonData));
        }

        _filteredRestaurants = _restaurants;

        if (_restaurants.isEmpty) {
          // Jika tidak ada restoran, set error
          Future.microtask(() => _setError('No restaurants available.',
              errorInternet: false, notfound: true));
        }
        return true;
      } else {
        // Jika tidak ada restoran di SQLite
        Future.microtask(() => _setError('Failed to load data',
            errorInternet: false, notfound: true));
        _restaurants = [];
        return false;
      }
    } on SocketException catch (e) {
      // Menangani masalah koneksi
      clearSearch();
      if (e.osError?.errorCode == 7) {
        Future.microtask(() => _setError(
            'Cannot connect to server. Please check your internet connection.',
            errorInternet: true));
      } else {
        Future.microtask(
            () => _setError('No internet connection.', errorInternet: true));
      }
      _restaurants = [];
      return false;
    } catch (e) {
      // Menangani error lainnya
      Future.microtask(
          () => _setError('Error: $e', errorInternet: false, notfound: true));
      _restaurants = [];
      return false;
    } finally {
      // Set loading ke false setelah selesai
      _setLoading(false);
    }
  }

  Future<void> searchRestaurantsFavorite(String query) async {
    if (query.isEmpty) {
      // Jika query kosong, tetap tampilkan pesan 'not found' jika data tidak ditemukan
      if (_filteredRestaurants.isEmpty) {
        _setError('No restaurants found.',
            errorInternet: false, notfound: true);
      }
      return;
    }

    _setError('');
    _setLoading(true);
    _searchQuery = query;
    _errorMessage = '';

    try {
      // Filter berdasarkan query pada list asli `_restaurants`
      _filteredRestaurants = _restaurants.where((restaurant) {
        return restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.city.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.description.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (_filteredRestaurants.isEmpty) {
        _setError('No restaurants found for your search.',
            errorInternet: false, notfound: true);
      }

      debugPrint(
          'Search results for "$query": ${_filteredRestaurants.toString()}');
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 7) {
        _setError(
            'Cannot connect to server. Please check your internet connection.',
            errorInternet: true);
      } else {
        _setError('No internet connection.', errorInternet: true);
      }
      _filteredRestaurants = [];
    } catch (e) {
      _setError('Error: $e', errorInternet: false, notfound: true);
      _filteredRestaurants = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
}
