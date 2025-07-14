import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_monitor/app_monitor.dart';

import 'exception_page.dart';

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

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final AppMonitor appMonitor;

  const MyApp({
    super.key,
    required this.scaffoldMessengerKey,
    required this.appMonitor,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: HomePage(appMonitor: appMonitor),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppMonitor appMonitor;

  const HomePage({super.key, required this.appMonitor});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _logs = [];
  final Set<int> _expandedLogs = {};

  Future<void> _fetchLogs() async {
    final logs = await widget.appMonitor.getAllLogs();
    setState(() => _logs = logs);
  }

  Future<void> _clearLogs() async {
    await widget.appMonitor.deleteAllLogs();
    await _fetchLogs();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All logs cleared')));
    }
  }

  Future<void> _deleteLog(int id) async {
    await widget.appMonitor.deleteLog(id);
    await _fetchLogs();
  }

  void _toggleExpand(int id) {
    setState(() {
      if (_expandedLogs.contains(id)) {
        _expandedLogs.remove(id);
      } else {
        _expandedLogs.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Monitor Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExceptionPage(),
                  ),
                );
              },
              child: const Text('Go to Exception Page'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => throw FormatException('Error'),
              child: const Text('FormatException'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => throw HttpException('Error'),
              child: const Text('HttpException'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => throw CertificateException('Error'),
              child: const Text('CertificateException'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchLogs,
              child: const Text('Show Logs'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _clearLogs,
              child: const Text('Clear Logs'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  final isExpanded = _expandedLogs.contains(log['id']);
                  final errorText =
                      log['error'].toString() + log['stackTrace'].toString();
                  final firstLine = errorText.split('\n').first;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () => _toggleExpand(log['id']),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Error ${log['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    log['timestamp'],
                                  ).toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(isExpanded ? errorText : firstLine),
                            if (!isExpanded && errorText.contains('\n'))
                              const Text(
                                '... (tap to expand)',
                                style: TextStyle(color: Colors.grey),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteLog(log['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
