import 'package:flutter/material.dart';

class ExceptionPage extends StatelessWidget {
  const ExceptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exception Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            throw Exception('This is a test exception');
          },
          child: const Text('Throw Exception'),
        ),
      ),
    );
  }
}