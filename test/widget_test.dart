import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/restoran_api.dart';
import 'package:restaurant_app/models/restorandet_api.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';
import 'package:restaurant_app/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late RestaurantProvider provider;
  late MockApiService mockApiService;
  late MockBuildContext mockBuildContext;

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantProvider(apiService: mockApiService);
    mockBuildContext = MockBuildContext();
  });

  group('RestaurantProvider Tests', () {
    test('Memastikan state awal provider harus didefinisikan', () {
      expect(provider.state, ResultState.idle);
      expect(provider.restaurants, isEmpty);
    });

    test('Mengembalikan daftar restoran saat API berhasil', () async {
      final mockData = List.generate(20, (index) => RestoranApiM(
        id: 'rqdv5juczeskfw1e${index + 1}',
        name: 'Restoran ${index + 1}',
        description: 'Deskripsi restoran ${index + 1}',
        pictureId: '${index + 1}',
        city: 'Kota ${index + 1}',
        rating: 4.0,
      ));

      when(mockApiService.fetchRestaurants()).thenAnswer((_) async => mockData);


      final result = await provider.fetchRestaurants();


      expect(result, isTrue);
      expect(provider.state, ResultState.hasData);
      expect(provider.restaurants.length, mockData.length);
    });


    test('Mengembalikan kesalahan saat API gagal', () async {
      when(mockApiService.fetchRestaurants()).thenThrow(Exception('Failed to load data'));


      final result = await provider.fetchRestaurants_error();
      debugPrint(result.toString());

      expect(result, isFalse);
      expect(provider.state, ResultState.error);
      expect(provider.errorMessage, 'Failed to load data');
    });

    test('Mengembalikan pencarian restoran saat API berhasil', () async {
      final mockData = [
        RestoranApiM(
          id: '1',
          name: 'Melting Pot',
          description: 'Test',
          pictureId: '14',
          city: 'Medan',
          rating: 4.2,
        ),
      ];

      when(mockApiService.searchRestaurants('Melting Pot')).thenAnswer((_) async => mockData);

      final result = await provider.searchRestaurantsApiTest('Melting Pot');

      expect(result, isTrue);
      expect(provider.state, ResultState.hasData);
      expect(provider.restaurants.length, mockData.length);
    });

    test('Mengembalikan pencarian restoran saat API gagal', () async {
      when(mockApiService.searchRestaurants('Melting Pot')).thenThrow(Exception('Failed to load search results'));

      final result = await provider.searchRestaurantsApiTestError('Melting Pot');

      expect(result, isFalse);
      expect(provider.state, ResultState.error);
      expect(provider.errorMessage, 'Failed to load search results');
    });


    test('Mengembalikan Detail restoran saat API berhasil', () async {
      final mockData = RestoranDetApiM(
        id: '1',
        name: 'Melting Pot',
        description: 'Test',
        city: 'Medan',
        address: '14',
        pictureId: '14',
        foods: [],
        drinks: [],
        categories: [],
        rating: 4.2,
        customerReviews: [],
      );


      when(mockApiService.fetchRestaurantDetailsList('rqdv5juczeskfw1e867'))
          .thenAnswer((_) async => mockData);


      final result = await provider.fetchRestaurantDetailsTest('rqdv5juczeskfw1e867');

      expect(result, isTrue);
      expect(provider.state, ResultState.hasData);
    });



    test('Memastikan provider menangani tidak ada koneksi internet', () async {
      when(mockApiService.fetchRestaurants()).thenThrow(const SocketException("No internet connection"));

      await provider.fetchRestaurants_error();

      expect(provider.state, ResultState.error);
      expect(provider.errorInternet, isTrue);
      expect(provider.message, equals('Failed to load data'));
    });
  });
}
