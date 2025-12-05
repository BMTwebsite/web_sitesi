import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'secrets.dart';
import 'pages/home_page.dart';
import 'pages/events_page.dart';
import 'pages/about_page.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_register_page.dart';
import 'pages/admin_verify_page.dart';
import 'pages/admin_panel_page.dart';

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
      title: 'BMT Web Sitesi',
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
      initialRoute: '/',
      routes: {
        '/home': (context) => const HomePage(),
        '/events': (context) => const EventsPage(),
        '/about': (context) => const AboutPage(),
        '/': (context) => const HomePage(),
        '/admin-login': (context) => const AdminLoginPage(),
        '/admin-register': (context) => const AdminRegisterPage(),
        '/admin-panel': (context) => const AdminPanelPage(),
        '/admin-verify': (context) {
          final uri = Uri.base;
          final token = uri.queryParameters['token'];
          return AdminVerifyPage(token: token);
        },
      },
      onGenerateRoute: (settings) {
        // Handle /verify?token=xxx route
        if (settings.name == '/verify') {
          final uri = Uri.parse(settings.name! + (settings.arguments as String? ?? ''));
          final token = uri.queryParameters['token'];
          return MaterialPageRoute(
            builder: (context) => AdminVerifyPage(token: token),
          );
        }
        return null;
      },
    );
  }
}
