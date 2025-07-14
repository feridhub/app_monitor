library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppMonitor {
  // Singleton pattern
  static final AppMonitor _instance = AppMonitor._internal();

  factory AppMonitor() => _instance;

  AppMonitor._internal();

  late Database _db;
  bool _initialized = false;

  // Public getter for database
  Database get db => _db;

  // Global navigator key
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  // Error callback
  static void Function(String error, StackTrace? stack)? onErrorCallback;

  // Initialize the monitor
  Future<void> initialize({
    required String appName,
    void Function(String error, StackTrace? stack)? onError,
  }) async {
    if (_initialized) return;

    // Initialize SQLite database
    _db = await openDatabase(
      join(await getDatabasesPath(), '${appName}_logs.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'error TEXT, stack TEXT, timestamp INTEGER)',
        );
      },
      version: 1,
    );

    // Initialize error callback
    onErrorCallback = onError;

    runZonedGuarded(
      () {
        // Set up error handlers
        FlutterError.onError = (details) {
          _recordError(details.exceptionAsString(), details.stack);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          _recordError(error.toString(), stack);
          return true; // Prevent app from crashing
        };
      },
      (error, stack) {
        // Catch all uncaught errors
        _recordError(error.toString(), stack);
      },
    );

    _initialized = true;
  }

  // Error recording
  Future<void> _recordError(String error, StackTrace? stack) async {
    await _db.insert('logs', {
      'error': error,
      'stack': stack?.toString() ?? 'No stack trace',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    if (onErrorCallback != null) {
      onErrorCallback!(error, stack);
    }
  }

  // Get all logs
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    return await _db.query('logs', orderBy: 'timestamp DESC');
  }

  // Delete all logs
  Future<int> deleteAllLogs() async {
    return await _db.delete('logs');
  }

  // Delete a specific log
  Future<int> deleteLog(int id) async {
    return await _db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }
}
