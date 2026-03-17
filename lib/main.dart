import 'package:flutter/material.dart';

void main() {
  runApp(const SereneLogApp());
}

class SereneLogApp extends StatelessWidget {
  const SereneLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SereneLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9E78), // Calm green
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        backgroundColor: Color(0xFF1A1F2E),
        body: Center(
          child: Text(
            '🌿 SereneLog',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}