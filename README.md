# AppMonitor - Flutter Error Monitoring & Logging Library

A comprehensive error monitoring and logging solution for Flutter applications that helps developers track, record, and manage errors efficiently with local SQLite storage and customizable error handling.

## Features ✨

- 📝 **Automatic Error Capturing** - Catches all Flutter framework errors and Dart runtime errors
- 💾 **Persistent Storage** - SQLite database for reliable error log persistence
- 🔍 **Detailed Error Reports** - Captures error messages, stack traces, and timestamps
- ⚡ **Performance Optimized** - Lightweight and non-blocking error recording
- 🛡️ **Crash Prevention** - Optional prevention of app crashes from uncaught exceptions
- � **Custom Error Handling** - Add your own error handling logic
- 🔄 **Log Management** - View, filter, and delete error logs
- 🧩 **Easy Integration** - Simple setup with powerful results
- 🌐 **Navigator Integration** - Built-in global navigator key for error dialogs

## Installation 💻

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  app_monitor: ^1.0.0
```

## Usage 🚀
```dart
import 'package:app_monitor/app_monitor.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final appMonitor = AppMonitor();

  // Initialize AppMonitor
  await appMonitor.initialize(
    appName: 'MyApp',
    onError: (error, stack) {
      debugPrint('Stack: $stack');

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(error)),
      );
    },
  );

  // Run the app
  runApp(
    MyApp(scaffoldMessengerKey: scaffoldMessengerKey, appMonitor: appMonitor),
  );
}
```

## Methods
```dart
Future<void> _fetchLogs() async {
  final logs = await widget.appMonitor.getAllLogs();
}

Future<void> _deleteLog(int id) async {
  await widget.appMonitor.deleteLog(id);
}

Future<void> _clearLogs() async {
  await widget.appMonitor.deleteAllLogs();
}
```

## License 📜
MIT License

Copyright (c) 2025 Ferid Cafer