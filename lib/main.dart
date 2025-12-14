import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'secrets.dart';
import 'dart:html' as html show window;
import 'pages/home_page.dart';
import 'pages/events_page.dart';
import 'pages/contact_page.dart';
import 'pages/about_page.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_register_page.dart';
import 'pages/admin_verify_page.dart';
import 'pages/admin_panel_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global hata yakalama
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('❌ Flutter Error: ${details.exception}');
    print('📚 Stack: ${details.stack}');
  };
  
  // Platform hatalarını yakala
  PlatformDispatcher.instance.onError = (error, stack) {
    print('❌ Platform Error: $error');
    print('📚 Stack: $stack');
    return true;
  };
  
  bool firebaseInitialized = false;
  
  try {
    print('🔄 Firebase başlatılıyor...');
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Secrets.firebaseApiKey,
        authDomain: Secrets.firebaseAuthDomain,
        projectId: Secrets.firebaseProjectId,
        storageBucket: Secrets.firebaseStorageBucket,
        messagingSenderId: Secrets.firebaseMessagingSenderId,
        appId: Secrets.firebaseAppId,
      ),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('⏱️ Firebase başlatma timeout oldu');
        throw 'Firebase başlatma zaman aşımına uğradı';
      },
    );
    firebaseInitialized = true;
    print('✅ Firebase başlatıldı');
  } catch (e, stackTrace) {
    print('❌ Firebase başlatma hatası: $e');
    print('📚 Stack trace: $stackTrace');
    firebaseInitialized = false;
    // Hata olsa bile uygulamayı çalıştırmaya devam et
  }
  
  runApp(BMTApp(firebaseInitialized: firebaseInitialized));
}

class BMTApp extends StatelessWidget {
  final bool firebaseInitialized;
  
  const BMTApp({super.key, this.firebaseInitialized = true});

  @override
  Widget build(BuildContext context) {
    // Firebase başlatılmadıysa hata göster
    if (!firebaseInitialized) {
      return MaterialApp(
        title: 'BMT Web Sitesi',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A1929),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Bağlantı Hatası',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase başlatılamadı. Lütfen:\n'
                    '1. İnternet bağlantınızı kontrol edin\n'
                    '2. Tarayıcı konsolunu açın (F12) ve hataları kontrol edin\n'
                    '3. lib/secrets.dart dosyasının doğru olduğundan emin olun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Sayfayı yenile
                      if (kIsWeb) {
                        // Web için
                        // ignore: avoid_web_libraries_in_flutter
                        // dart:html kullanmadan window.location.reload() yapamayız
                        // Kullanıcıya manuel yenileme söyleyelim
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Sayfayı Yenile',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
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
        '/': (context) => const HomePage(),
        '/home': (context) => const HomePage(),
        '/events': (context) => const EventsPage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
        '/admin-login': (context) => const AdminLoginPage(),
        '/admin-register': (context) => const AdminRegisterPage(),
        '/admin-panel': (context) => const AdminPanelPage(),
        '/admin-verify': (context) {
          // Hash routing için query parametrelerini al
          String? token;
          if (kIsWeb) {
            try {
              // Hash routing kullanıldığında, query parametreleri hash içinde olabilir
              // window.location.hash formatı: #/admin-verify?token=xxx
              final hash = html.window.location.hash;
              print('🔍 Hash routing - Hash: $hash');
              
              if (hash.isNotEmpty) {
                // Hash'ten query parametrelerini parse et
                // Format: #/admin-verify?token=xxx
                final hashParts = hash.split('?');
                print('🔍 Hash parts: $hashParts');
                
                if (hashParts.length > 1) {
                  final queryString = hashParts[1];
                  print('🔍 Query string: $queryString');
                  final queryUri = Uri.parse('?$queryString');
                  token = queryUri.queryParameters['token'];
                  print('🔍 Token from hash: $token');
                }
              }
              
              // Eğer hash'ten bulunamazsa, Uri.base'den dene
              if (token == null || token.isEmpty) {
                final baseUri = Uri.base;
                print('🔍 Uri.base: $baseUri');
                token = baseUri.queryParameters['token'];
                print('🔍 Token from Uri.base: $token');
              }
              
              // Son çare: window.location.search'ten dene
              if (token == null || token.isEmpty) {
                try {
                  // ignore: avoid_web_libraries_in_flutter
                  final search = html.window.location.search;
                  print('🔍 Location search: $search');
                  if (search != null && search.isNotEmpty) {
                    final searchUri = Uri.parse(search);
                    token = searchUri.queryParameters['token'];
                    print('🔍 Token from search: $token');
                  }
                } catch (e) {
                  print('⚠️ Search parse hatası: $e');
                }
              }
            } catch (e) {
              print('❌ Query parameter parse hatası: $e');
              // Fallback: Uri.base'den dene
              token = Uri.base.queryParameters['token'];
            }
          } else {
            token = Uri.base.queryParameters['token'];
          }
          
          print('✅ Final token: $token');
          return AdminVerifyPage(token: token);
        },
      },
      onGenerateRoute: (settings) {
        // Handle /verify?token=xxx route
        if (settings.name == '/verify') {
          final uri = Uri.parse(
            settings.name! + (settings.arguments as String? ?? ''),
          );
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
