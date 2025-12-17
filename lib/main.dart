import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'secrets.dart';
import 'dart:html' as html;
import 'pages/home_page.dart';
import 'pages/events_page.dart';
import 'pages/announcements_page.dart';
import 'pages/contact_page.dart';
import 'pages/about_page.dart';
import 'pages/team_page.dart';
import 'pages/sponsors_page.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_register_page.dart';
import 'pages/admin_verify_page.dart';
import 'pages/admin_panel_page.dart';
import 'providers/auth_provider.dart';
import 'providers/firestore_provider.dart';
import 'utils/custom_page_route.dart';

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
  String? firebaseError;
  
  try {
    print('🔄 Firebase başlatılıyor...');
    print('📋 Firebase Config:');
    print('   - Project ID: ${Secrets.firebaseProjectId}');
    print('   - Auth Domain: ${Secrets.firebaseAuthDomain}');
    
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
        print('⏱️ Firebase başlatma timeout oldu (10 saniye)');
        print('⚠️ İnternet bağlantınızı kontrol edin');
        throw 'Firebase başlatma zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
      },
    );
    firebaseInitialized = true;
    print('✅ Firebase başarıyla başlatıldı');
  } catch (e, stackTrace) {
    print('❌ Firebase başlatma hatası: $e');
    print('📚 Stack trace: $stackTrace');
    firebaseInitialized = false;
    firebaseError = e.toString();
    // Hata olsa bile uygulamayı çalıştırmaya devam et
  }
  
  runApp(BMTApp(firebaseInitialized: firebaseInitialized, firebaseError: firebaseError));
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
  final String? firebaseError;
  
  const BMTApp({super.key, this.firebaseInitialized = true, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    // Firebase başlatılmadıysa hata göster
    if (!firebaseInitialized) {
      return MaterialApp(
        title: 'BMT Web Sitesi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF2196F3),
            secondary: const Color(0xFFF44336),
            surface: const Color(0xFF0A0E17),
            background: const Color(0xFF0A0E17),
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0E17),
        ),
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
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
                  Text(
                    'Firebase başlatılamadı. Bu genellikle internet bağlantısı sorunundan kaynaklanır.\n\n'
                    'Lütfen şunları kontrol edin:\n\n'
                    '1. ✅ İnternet bağlantınızın aktif olduğundan emin olun\n'
                    '2. ✅ VPN kullanıyorsanız kapatıp tekrar deneyin\n'
                    '3. ✅ Tarayıcı konsolunu açın (F12) ve hataları kontrol edin\n'
                    '4. ✅ Sayfayı yenileyin (F5)\n\n'
                    '${firebaseError != null ? 'Hata Detayı:\n$firebaseError\n\n' : ''}'
                    '${kIsWeb ? '💡 İpucu: Tarayıcı konsolunu (F12) açarak daha detaylı hata bilgisi görebilirsiniz.' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Sayfayı yenile
                      if (kIsWeb) {
                        html.window.location.reload();
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
        // Tüm sayfaları tam ekran yap
        builder: (context, child) {
          if (!kIsWeb) {
            return child ?? const SizedBox();
          }
          
          try {
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = mediaQuery.size.width;
            final screenHeight = mediaQuery.size.height;
            
            // Tam ekran container
            return MediaQuery(
              data: mediaQuery.copyWith(
                size: Size(screenWidth, screenHeight),
                padding: EdgeInsets.zero,
              ),
              child: Container(
                width: screenWidth,
                height: screenHeight,
                color: const Color(0xFF0A1929),
                child: child ?? const SizedBox(),
              ),
            );
          } catch (e) {
            print('❌ Builder hatası: $e');
            return child ?? const SizedBox();
          }
        },
        // Web'de hash kontrolü yap - eğer admin-verify varsa direkt AdminVerifyPage döndür
        home: kIsWeb ? (_getHomeWidget() ?? const HomePage()) : const HomePage(),
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
                  
                  return CustomPageRoute(
                    settings: settings,
                    child: AdminVerifyPage(token: token),
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
            return CustomPageRoute(
              settings: settings,
              child: AdminVerifyPage(token: token),
            );
          }
          
          // Normal route'lar için custom transition kullan
          Widget? page;
          switch (settings.name) {
            case '/home':
            case '/':
              page = const HomePage();
              break;
            case '/events':
              page = const EventsPage();
              break;
            case '/announcements':
              page = const AnnouncementsPage();
              break;
            case '/about':
              page = const AboutPage();
              break;
            case '/team':
              page = const TeamPage();
              break;
            case '/sponsor':
              page = const SponsorsPage();
              break;
            case '/contact':
              page = const ContactPage();
              break;
            case '/admin-login':
              page = const AdminLoginPage();
              break;
            case '/admin-register':
              page = const AdminRegisterPage();
              break;
            case '/admin-panel':
              page = const AdminPanelPage();
              break;
            case '/admin-verify':
              // Hash routing için query parametrelerini al
              String? token;
              if (kIsWeb) {
                try {
                  final fullUrl = html.window.location.href;
                  final hash = html.window.location.hash;
                  final search = html.window.location.search ?? '';
                  
                  // Yöntem 1: Hash'ten parse et
                  if (hash.isNotEmpty) {
                    if (hash.contains('?')) {
                      final hashParts = hash.split('?');
                      if (hashParts.length > 1) {
                        try {
                          final queryUri = Uri.parse('?${hashParts[1]}');
                          token = queryUri.queryParameters['token'];
                        } catch (e) {
                          print('⚠️ Hash query parse hatası: $e');
                        }
                      }
                    }
                    
                    if (token == null || token.isEmpty) {
                      final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
                      if (tokenMatch != null) {
                        token = Uri.decodeComponent(tokenMatch.group(1)!);
                      }
                    }
                  }
                  
                  // Yöntem 2: Search'ten parse et
                  if ((token == null || token.isEmpty) && search.isNotEmpty) {
                    try {
                      final searchUri = Uri.parse(search);
                      token = searchUri.queryParameters['token'];
                    } catch (e) {
                      print('⚠️ Search parse hatası: $e');
                    }
                  }
                  
                  // Yöntem 3: Full URL'den parse et
                  if (token == null || token.isEmpty) {
                    try {
                      final fullUri = Uri.parse(fullUrl);
                      token = fullUri.queryParameters['token'];
                      
                      if ((token == null || token.isEmpty) && fullUri.hasFragment) {
                        final fragment = fullUri.fragment;
                        if (fragment.isNotEmpty && fragment.contains('token=')) {
                          final fragmentParts = fragment.split('token=');
                          if (fragmentParts.length > 1) {
                            final tokenPart = fragmentParts[1].split('&')[0].split('#')[0];
                            if (tokenPart.isNotEmpty) {
                              token = Uri.decodeComponent(tokenPart);
                            }
                          }
                        }
                      }
                    } catch (e) {
                      print('⚠️ Full URL parse hatası: $e');
                    }
                  }
                  
                  // Yöntem 4: Uri.base'den dene
                  if (token == null || token.isEmpty) {
                    token = Uri.base.queryParameters['token'];
                  }
                } catch (e, stackTrace) {
                  print('❌ Query parameter parse hatası: $e');
                  print('📚 Stack trace: $stackTrace');
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
              page = AdminVerifyPage(token: token);
              break;
          }
          
          if (page != null) {
            return CustomPageRoute(
              settings: settings,
              child: page,
            );
          }
          
          return null;
        },
      ),
    );
  }
}
