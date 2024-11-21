import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:restaurant_app/models/restaurant_lite.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider with ChangeNotifier {
  Database? _database;
  static final DatabaseProvider instance = DatabaseProvider();

  DatabaseProvider();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurant.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE restaurants (
        id TEXT PRIMARY KEY,
        json_data TEXT,
        time_added TEXT
      )
    ''');
  }

  Future<void> insertRestaurant(Restaurant restaurant) async {
    final db = await instance.database;
    await db.insert('restaurants', restaurant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Restaurant?> getRestaurant(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'restaurants',
      columns: ['id', 'json_data', 'time_added'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Restaurant.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> deleteRestaurant(String id) async {
    final db = await instance.database;
    await db.delete('restaurants', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> isRestaurantExist(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'restaurants',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    final db = await instance.database;
    final maps = await db.query(
      'restaurants',
      columns: ['id', 'json_data', 'time_added'],
    );

    if (maps.isNotEmpty) {
      return maps.map((map) => Restaurant.fromMap(map)).toList();
    } else {
      return [];
    }
  }
}
