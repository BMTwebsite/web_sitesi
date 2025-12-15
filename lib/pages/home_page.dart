import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'dart:html' as html show window;
import 'admin_verify_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _eventsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Web'de URL kontrolü yap
    if (kIsWeb) {
      // Hemen kontrol et
      _checkVerificationToken();
      // PostFrameCallback ile de kontrol et (güvenlik için)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkVerificationToken();
      });
    }
  }

  void _checkVerificationToken() {
    if (!mounted) return;
    
    try {
      final hash = html.window.location.hash;
      final fullUrl = html.window.location.href;
      final search = html.window.location.search ?? '';
      
      print('🔍 HomePage - URL kontrolü başlatılıyor...');
      print('🔍 HomePage - Hash: $hash');
      print('🔍 HomePage - Search: $search');
      print('🔍 HomePage - Full URL: $fullUrl');
      
      String? token;
      
      // Yöntem 1: Hash'ten token parse et
      if (hash.isNotEmpty) {
        if (hash.contains('/admin-verify') && hash.contains('token=')) {
          print('✅ HomePage - Admin verify linki hash\'te tespit edildi');
          final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
          if (tokenMatch != null && tokenMatch.group(1) != null) {
            token = Uri.decodeComponent(tokenMatch.group(1)!);
            print('✅ HomePage - Token hash\'ten bulundu: $token');
          }
        }
      }
      
      // Yöntem 2: Search'ten token parse et
      if ((token == null || token.isEmpty) && search.isNotEmpty) {
        try {
          final searchUri = Uri.parse(search);
          token = searchUri.queryParameters['token'];
          if (token != null && token.isNotEmpty) {
            print('✅ HomePage - Token search\'ten bulundu: $token');
          }
        } catch (e) {
          print('⚠️ HomePage - Search parse hatası: $e');
        }
      }
      
      // Yöntem 3: Full URL'den token parse et
      if (token == null || token.isEmpty) {
        try {
          final fullUri = Uri.parse(fullUrl);
          token = fullUri.queryParameters['token'];
          if (token != null && token.isNotEmpty) {
            print('✅ HomePage - Token full URL\'den bulundu: $token');
          }
        } catch (e) {
          print('⚠️ HomePage - Full URL parse hatası: $e');
        }
      }
      
      // Token bulunduysa AdminVerifyPage'e yönlendir
      if (token != null && token.isNotEmpty) {
        print('✅ HomePage - Token bulundu, AdminVerifyPage\'e yönlendiriliyor: $token');
        // Hemen yönlendir (microtask yerine direkt)
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AdminVerifyPage(token: token),
            ),
            (route) => false, // Tüm önceki route'ları temizle
          );
        }
      } else {
        print('⚠️ HomePage - Token bulunamadı');
      }
    } catch (e, stackTrace) {
      print('❌ HomePage - URL kontrolü hatası: $e');
      print('📚 Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web'de hash kontrolü yap - eğer admin-verify varsa direkt AdminVerifyPage döndür
    if (kIsWeb) {
      try {
        final hash = html.window.location.hash;
        if (hash.contains('/admin-verify') && hash.contains('token=')) {
          final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
          if (tokenMatch != null && tokenMatch.group(1) != null) {
            final token = Uri.decodeComponent(tokenMatch.group(1)!);
            print('✅ HomePage build - Token bulundu, AdminVerifyPage döndürülüyor: $token');
            return AdminVerifyPage(token: token);
          }
        }
      } catch (e) {
        print('⚠️ HomePage build hash kontrolü hatası: $e');
      }
    }
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(eventsKey: _eventsKey),
            _HeroSection(),
            _EventsSection(key: _eventsKey),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final GlobalKey? eventsKey;

  const _Header({this.eventsKey});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  final _authService = AuthService();
  String _currentRoute = '/';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          InkWell(
            onTap: () {
              setState(() => _currentRoute = '/');
              Navigator.pushNamed(context, '/');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.memory,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'BMT',
                  style: TextStyle(
                    color: Color(0xFF0A1929),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Navigation Menu
          Row(
            children: [
              _NavItem(
                text: 'Ana Sayfa',
                route: '/',
                isActive: _currentRoute == '/',
                onTap: () {
                  setState(() => _currentRoute = '/');
                  Navigator.pushNamed(context, '/');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Hakkımızda',
                route: '/about',
                isActive: _currentRoute == '/about',
                onTap: () {
                  setState(() => _currentRoute = '/about');
                  // TODO: Implement about page
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Etkinlik',
                route: '/events',
                isActive: _currentRoute == '/events',
                onTap: () {
                  setState(() => _currentRoute = '/events');
                  if (widget.eventsKey?.currentContext != null) {
                    Scrollable.ensureVisible(
                      widget.eventsKey!.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Ekip',
                route: '/team',
                isActive: _currentRoute == '/team',
                onTap: () {
                  setState(() => _currentRoute = '/team');
                  // TODO: Implement team page
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Sponsor',
                route: '/sponsor',
                isActive: _currentRoute == '/sponsor',
                onTap: () {
                  setState(() => _currentRoute = '/sponsor');
                  // TODO: Implement sponsor page
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'İletişim',
                route: '/contact',
                isActive: _currentRoute == '/contact',
                onTap: () {
                  setState(() => _currentRoute = '/contact');
                  Navigator.pushNamed(context, '/contact');
                },
              ),
            ],
          ),
          // Giriş Butonu
          StreamBuilder(
            stream: _authService.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              final isLoggedIn = snapshot.hasData;

              if (isLoggedIn) {
                return FutureBuilder<bool>(
                  future: _authService.isAdmin(),
                  builder: (context, adminSnapshot) {
                    if (adminSnapshot.data == true) {
                      return Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/admin-panel');
                            },
                            icon: const Icon(Icons.admin_panel_settings, size: 18),
                            label: const Text('Admin Paneli'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _authService.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Çıkış yapıldı'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Çıkış'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/admin-login');
                      },
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Giriş Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    );
                  },
                );
              }

              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin-login');
                },
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String text;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.text,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cable,
                        color: Color(0xFF2196F3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bilgisayar Mühendisliği Topluluğu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Kodla Geleceği',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Tasarla Yarını',
                  style: TextStyle(
                    color: Color(0xFFF44336),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Birlikte Başaralım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bilgisayar Mühendisliği Topluluğu olarak, teknolojiye tutkulu öğrencileri bir araya getiriyor, bilgi paylaşımını ve inovasyonu destekliyoruz.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Container(
              height: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1A2332),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsSection extends StatelessWidget {
  final _firestoreService = FirestoreService();

  _EventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yaklaşan Etkinlikler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Yaklaşan etkinliklerimize göz atın',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          StreamBuilder<List<EventData>>(
            stream: _firestoreService.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Etkinlikler yüklenirken bir hata oluştu: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Henüz etkinlik eklenmemiş.',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                );
              }

              final events = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _EventCard(events[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventData event;

  const _EventCard(this.event);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _EventInfo(icon: Icons.calendar_today, text: event.date),
                  const SizedBox(height: 8),
                  _EventInfo(icon: Icons.access_time, text: event.time),
                  const SizedBox(height: 8),
                  _EventInfo(icon: Icons.location_on, text: event.location),
                  const Spacer(),
                  _EventInfo(
                    icon: Icons.people,
                    text: '${event.participants} Katılımcı',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
      color: const Color(0xFF0A1929),
      child: Column(
        children: [
          const Text(
            '© 2025 Bilgisayar Mühendisliği Topluluğu. Tüm hakları saklıdır.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

