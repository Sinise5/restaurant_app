import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/restoran_api.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/screens/restaurant_det_screen.dart';
import 'package:restaurant_app/widgets/loading_indicator.dart';

import '../providers/restaurant_provider.dart';

class RestoranApi extends StatefulWidget {
  const RestoranApi({super.key});

  @override
  State<RestoranApi> createState() => _RestoranApiState();
}

class _RestoranApiState extends State<RestoranApi> {
  var isDeviceConnected = false;
  final List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _checkConnectivityAndFetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkConnectivityAndFetchData() async {
    Provider.of<RestaurantProvider>(context, listen: false)
        .checkAndFetchData(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    return Scaffold(
        backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
        body: StreamBuilder<ConnectivityResult>(
            stream: null,
            builder: (context, snapshot) {
              final connectionStatus = snapshot.data;

              /*
              if (connectionStatus == ConnectivityResult.none) {
                NoInternetDialog.show(
                  context,
                  "Tidak ada koneksi internet. Silakan coba lagi nanti.",
                      () async {
                    return await Provider.of<RestaurantProvider>(
                      context,
                      listen: false,
                    ).fetchRestaurants();
                  },
                );
                debugPrint('xxxxxx Tidak ada internet');
              } else if (connectionStatus == ConnectivityResult.wifi ||
                  connectionStatus == ConnectivityResult.mobile) {
                Provider.of<RestaurantProvider>(context, listen: false)
                    .fetchRestaurants();
              }*/

              return Consumer<RestaurantProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    onRefresh: _checkConnectivityAndFetchData,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildSearchBoxApi(),
                        provider.isLoading
                            ? const LoadingIndicator()
                            : (provider.errorInternet)
                                ? const Expanded(
                                    child: Center(
                                      child: Text(
                                          'No internet connection. Please try again later.'),
                                    ),
                                  )
                                : (provider.notfound)
                                    ? const Expanded(
                                        child: Center(
                                          child: Text('No data available'),
                                        ),
                                      )
                                    : provider.restaurants.isEmpty &&
                                            provider.searchQuery.isNotEmpty
                                        ? const Expanded(
                                            child: Center(
                                              child: Text(
                                                  'No restaurants found for your search.'),
                                            ),
                                          )
                                        : (provider.restaurants.isEmpty) &&
                                                (_connectionStatus.contains(
                                                    ConnectivityResult.none))
                                            ? const Expanded(
                                                child: Center(
                                                  child: Text(
                                                      'No internet connection. Please try again later.'),
                                                ),
                                              )
                                            : provider.restaurants.isEmpty
                                                ? const Expanded(
                                                    child: Center(
                                                      child: Text(
                                                          'No data available'),
                                                    ),
                                                  )
                                                : _buildRestaurantList(
                                                    provider.restaurants),
                      ],
                    ),
                  );
                },
              );
            }));
  }

  Widget _buildSearchBoxApi() {
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search by name...",
          hintStyle: TextStyle(
            color: themeProvider.textColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: themeProvider.currentTheme.scaffoldBackgroundColor,
          prefixIcon: Icon(Icons.search,
              color: themeProvider.currentTheme.iconTheme.color),
        ),
        style: TextStyle(
          color: themeProvider.textColor,
        ),
        onChanged: (query) {
          final provider =
              Provider.of<RestaurantProvider>(context, listen: false);
          if (query.isEmpty) {
            provider.clearSearch();
          } else {
            provider.searchRestaurantsApi(query);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_rounded,
              color: themeProvider.currentTheme.iconTheme.color,
              size: 30,
            ),
          ),
          Text(
            "Restaurant",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.currentTheme.textTheme.bodyMedium?.color),
          ),
          Icon(
            Icons.list_alt_outlined,
            color: themeProvider.currentTheme.iconTheme.color,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList(List<RestoranApiM> restaurants) {
    return Expanded(
      child: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RestorandetApi(restaurantId: restaurant.id),
                ),
              );
            },
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://restaurant-api.dicoding.dev/images/small/${restaurant.pictureId}',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.city,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Rating: ${restaurant.rating}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.teal, size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
