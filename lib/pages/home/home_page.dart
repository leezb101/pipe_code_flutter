import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Flutter Bloc Template!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'This is a clean architecture template with:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '• Bloc/Cubit for state management',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• GoRouter for navigation',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Clean architecture patterns',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Dependency injection with GetIt',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}