import 'package:app_monitor/app_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppMonitor Singleton Test', () {
    test('Should return the same instance', () {
      final instance1 = AppMonitor();
      final instance2 = AppMonitor();
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('AppMonitor Initialization', () {
    late AppMonitor monitor;

    setUp(() async {
      monitor = AppMonitor();
      await monitor.initialize(appName: 'test_app');
    });

    tearDown(() async {
      await monitor.deleteAllLogs();
    });

    test('Should initialize database', () async {
      expect(monitor.db, isNotNull);
    });

    test('Should not initialize twice', () async {
      final db = monitor.db;
      await monitor.initialize(appName: 'test_app');
      expect(identical(db, monitor.db), isTrue);
    });
  });

  group('Error Handling', () {
    late AppMonitor monitor;

    setUp(() async {
      monitor = AppMonitor();
      await monitor.initialize(
        appName: 'test_app',
        onError: (error, stack) {
        },
      );
    });

    tearDown(() async {
      await monitor.deleteAllLogs();
    });
  });

  group('Navigation Test', () {
    late AppMonitor monitor;

    setUp(() async {
      monitor = AppMonitor();
      await monitor.initialize(appName: 'test_app');

      final key = AppMonitor.rootNavigatorKey;
      Navigator(
        key: key,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: Center(child: Text('Second Page')),
                              ),
                            ),
                          );
                        },
                        child: const Text('Navigate'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          throw Exception('Test Error');
                        },
                        child: const Text('Throw Error'),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ) as NavigatorState;
    });

    tearDown(() async {
      await monitor.deleteAllLogs();
    });
  });

  group('Edge Cases', () {
    test('Should handle database errors gracefully', () async {
      final monitor = AppMonitor();
      // Force database error by using invalid path
      try {
        await monitor.initialize(appName: '/invalid/name/');
        fail('Should throw an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('Should work without error callback', () async {
      final monitor = AppMonitor();
      await monitor.initialize(appName: 'test_app');

      FlutterError.onError!(FlutterErrorDetails(
        exception: 'Test Error',
        stack: StackTrace.current,
      ));

      final logs = await monitor.getAllLogs();
      expect(logs.length, 1);
    });
  });


}
