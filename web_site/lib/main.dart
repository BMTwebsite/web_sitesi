import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/events_page.dart';

void main() {
  runApp(const BMTApp());
}

class BMTApp extends StatelessWidget {
  const BMTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilgisayar Mühendisliği Topluluğu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFFF44336),
          surface: const Color(0xFF0A1929),
          background: const Color(0xFF0A1929),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A1929),
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/events': (context) => const EventsPage(),
      },
    );
  }
}
