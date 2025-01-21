import 'package:flutter/material.dart';
import 'package:edu_app/home_page.dart';
import 'package:edu_app/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educational app',
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
