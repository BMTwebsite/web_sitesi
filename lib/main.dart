import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/home_page.dart';
import 'pages/events_page.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_panel_page.dart';
import 'secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Secrets.firebaseApiKey,
      authDomain: Secrets.firebaseAuthDomain,
      projectId: Secrets.firebaseProjectId,
      storageBucket: Secrets.firebaseStorageBucket,
      messagingSenderId: Secrets.firebaseMessagingSenderId,
      appId: Secrets.firebaseAppId,
    ),
  );
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
        '/admin-login': (context) => const AdminLoginPage(),
        '/admin': (context) => const AdminPanelPage(),
      },
    );
  }
}
