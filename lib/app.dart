import 'package:flutter/material.dart';
import 'screens/clock_home_screen.dart';

class TempoClockApp extends StatelessWidget {
  const TempoClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B1020);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tempo Clock',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF151C30),
        ),
        fontFamily: 'Roboto',
      ),
      home: const ClockHomeScreen(),
    );
  }
}