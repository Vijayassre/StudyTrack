
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const StudyTrackApp());
}

class StudyTrackApp extends StatelessWidget {
  const StudyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyTrack',

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8F6FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE6DCFF),
          foregroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
