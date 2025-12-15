import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
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
import 'providers/auth_provider.dart';
import 'providers/firestore_provider.dart';

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

// Web'de hash kontrolü yap - eğer admin-verify varsa direkt AdminVerifyPage döndür
Widget? _getHomeWidget() {
  if (!kIsWeb) return null;
  
  try {
    final hash = html.window.location.hash;
    print('🔍 _getHomeWidget - Hash kontrolü: $hash');
    
    if (hash.contains('/admin-verify') && hash.contains('token=')) {
      print('✅ _getHomeWidget - Admin verify linki tespit edildi');
      final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
      if (tokenMatch != null && tokenMatch.group(1) != null) {
        final token = Uri.decodeComponent(tokenMatch.group(1)!);
        print('✅ _getHomeWidget - Token bulundu, AdminVerifyPage döndürülüyor: $token');
        return AdminVerifyPage(token: token);
      }
    }
  } catch (e) {
    print('⚠️ _getHomeWidget hash kontrolü hatası: $e');
  }
  
  return null;
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
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FirestoreProvider()),
      ],
      child: MaterialApp(
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
        // Web'de hash kontrolü yap - eğer admin-verify varsa direkt AdminVerifyPage döndür
        home: kIsWeb ? (_getHomeWidget() ?? const HomePage()) : const HomePage(),
        routes: {
        // '/' route'u kaldırıldı çünkü home property kullanılıyor
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
              // ignore: avoid_web_libraries_in_flutter
              final fullUrl = html.window.location.href;
              final hash = html.window.location.hash;
              final search = html.window.location.search ?? '';
              
              print('🔍 Full URL: $fullUrl');
              print('🔍 Hash: $hash');
              print('🔍 Search: $search');
              
              // Yöntem 1: Hash'ten parse et (#/admin-verify?token=xxx)
              if (hash.isNotEmpty) {
                // Hash formatı: #/admin-verify?token=xxx
                if (hash.contains('?')) {
                  final hashParts = hash.split('?');
                  if (hashParts.length > 1) {
                    final queryString = hashParts[1];
                    print('🔍 Query string from hash: $queryString');
                    try {
                      final queryUri = Uri.parse('?$queryString');
                      token = queryUri.queryParameters['token'];
                      print('🔍 Token from hash query: $token');
                    } catch (e) {
                      print('⚠️ Hash query parse hatası: $e');
                    }
                  }
                }
                
                // Alternatif: Hash içinde direkt token ara
                if (token == null || token.isEmpty) {
                  final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
                  if (tokenMatch != null) {
                    token = Uri.decodeComponent(tokenMatch.group(1)!);
                    print('🔍 Token from hash regex: $token');
                  }
                }
              }
              
              // Yöntem 2: Search'ten parse et (?token=xxx)
              if ((token == null || token.isEmpty) && search.isNotEmpty) {
                try {
                  final searchUri = Uri.parse(search);
                  token = searchUri.queryParameters['token'];
                  print('🔍 Token from search: $token');
                } catch (e) {
                  print('⚠️ Search parse hatası: $e');
                }
              }
              
              // Yöntem 3: Full URL'den parse et
              if (token == null || token.isEmpty) {
                try {
                  final fullUri = Uri.parse(fullUrl);
                  token = fullUri.queryParameters['token'];
                  print('🔍 Token from full URL: $token');
                  
                  // Hash fragment'ten de dene
                  if ((token == null || token.isEmpty) && fullUri.hasFragment) {
                    final fragment = fullUri.fragment;
                    if (fragment.isNotEmpty && fragment.contains('token=')) {
                      final fragmentParts = fragment.split('token=');
                      if (fragmentParts.length > 1) {
                        final tokenPart = fragmentParts[1].split('&')[0].split('#')[0];
                        if (tokenPart.isNotEmpty) {
                          token = Uri.decodeComponent(tokenPart);
                          print('🔍 Token from fragment: $token');
                        }
                      }
                    }
                  }
                } catch (e) {
                  print('⚠️ Full URL parse hatası: $e');
                }
              }
              
              // Yöntem 4: Uri.base'den dene (fallback)
              if (token == null || token.isEmpty) {
                final baseUri = Uri.base;
                token = baseUri.queryParameters['token'];
                print('🔍 Token from Uri.base: $token');
              }
            } catch (e, stackTrace) {
              print('❌ Query parameter parse hatası: $e');
              print('📚 Stack trace: $stackTrace');
              // Son çare: Uri.base'den dene
              try {
                token = Uri.base.queryParameters['token'];
              } catch (e2) {
                print('❌ Uri.base parse hatası: $e2');
              }
            }
          } else {
            token = Uri.base.queryParameters['token'];
          }
          
          print('✅ Final token: $token');
          if (token == null || token.isEmpty) {
            print('⚠️ Token bulunamadı! URL formatını kontrol edin.');
          }
          return AdminVerifyPage(token: token);
        },
      },
      onGenerateRoute: (settings) {
        print('🔍 onGenerateRoute çağrıldı: ${settings.name}');
        
        // Web'de hash routing kontrolü
        if (kIsWeb) {
          try {
            final hash = html.window.location.hash;
            final fullUrl = html.window.location.href;
            
            print('🔍 onGenerateRoute - Hash: $hash');
            print('🔍 onGenerateRoute - Full URL: $fullUrl');
            
            // Eğer hash'te admin-verify varsa
            if (hash.contains('/admin-verify') && hash.contains('token=')) {
              print('✅ onGenerateRoute - Admin verify linki tespit edildi');
              
              // Token'ı parse et
              String? token;
              final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
              if (tokenMatch != null && tokenMatch.group(1) != null) {
                token = Uri.decodeComponent(tokenMatch.group(1)!);
                print('✅ onGenerateRoute - Token bulundu: $token');
                
                return MaterialPageRoute(
                  builder: (context) => AdminVerifyPage(token: token),
                );
              }
            }
          } catch (e) {
            print('⚠️ onGenerateRoute hash kontrolü hatası: $e');
          }
        }
        
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
      ),
    );
  }
}
