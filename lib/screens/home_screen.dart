import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Center(
        child: Text('Home Screen - Coming Soon',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}