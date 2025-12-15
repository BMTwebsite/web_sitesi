import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/firestore_provider.dart';
import '../services/auth_service.dart';
import '../utils/size_helper.dart';
import 'dart:html' as html show window;
import 'admin_verify_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    // URL kontrolü initState'de yapılıyor, burada tekrar kontrol etmeye gerek yok
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _Header(),
            const _AnnouncementsAlertSection(),
            const _HeroSection(),
            const _AboutSection(),
            const _EventsSection(),
            const _TeamSection(),
            const _SponsorsSection(),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  final _authService = AuthService();
  String _currentRoute = '/';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E17),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 40,
        vertical: 20,
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
                    width: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Logo width'),
                    height: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Logo height'),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.memory,
                      color: Colors.white,
                      size: SizeHelper.safeSize(value: 24, min: 16, max: 32, context: 'Logo icon size'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'BMT',
                  style: TextStyle(
                    color: const Color(0xFF0A1929),
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 24),
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
                  Navigator.pushNamed(context, '/about');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Etkinlik',
                route: '/events',
                isActive: _currentRoute == '/events',
                onTap: () {
                  setState(() => _currentRoute = '/events');
                  Navigator.pushNamed(context, '/events');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Duyurular',
                route: '/announcements',
                isActive: _currentRoute == '/announcements',
                onTap: () {
                  setState(() => _currentRoute = '/announcements');
                  Navigator.pushNamed(context, '/announcements');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Ekip',
                route: '/team',
                isActive: _currentRoute == '/team',
                onTap: () {
                  setState(() => _currentRoute = '/team');
                  Navigator.pushNamed(context, '/team');
                },
              ),
              const SizedBox(width: 30),
              _NavItem(
                text: 'Sponsor',
                route: '/sponsor',
                isActive: _currentRoute == '/sponsor',
                onTap: () {
                  setState(() => _currentRoute = '/sponsor');
                  Navigator.pushNamed(context, '/sponsor');
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
                            icon: Icon(Icons.admin_panel_settings, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                            label: const Text('Admin Paneli'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Button padding horizontal'),
                                vertical: SizeHelper.safeSize(value: 12, min: 6, max: 24, context: 'Button padding vertical'),
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
                            icon: Icon(Icons.logout, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                            label: const Text('Çıkış'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Button padding horizontal'),
                                vertical: SizeHelper.safeSize(value: 12, min: 6, max: 24, context: 'Button padding vertical'),
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
                      icon: Icon(Icons.login, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                      label: const Text('Giriş Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Button padding horizontal'),
                          vertical: SizeHelper.safeSize(value: 12, min: 6, max: 24, context: 'Button padding vertical'),
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
                icon: Icon(Icons.login, size: SizeHelper.safeSize(value: 18, min: 12, max: 24, context: 'Button icon size')),
                label: const Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Button padding horizontal'),
                    vertical: SizeHelper.safeSize(value: 12, min: 6, max: 24, context: 'Button padding vertical'),
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
          fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0E17),
            const Color(0xFF1A2332).withOpacity(0.3),
            const Color(0xFF0A0E17),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 80,
      ),
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
                Text(
                  'Kodla Geleceği',
                  style: TextStyle(
                    color: const Color(0xFF2196F3),
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                Text(
                  'Tasarla Yarını',
                  style: TextStyle(
                    color: const Color(0xFFF44336),
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                Text(
                  'Birlikte Başaralım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Bilgisayar Mühendisliği Topluluğu olarak, teknolojiye tutkulu öğrencileri bir araya getiriyor, bilgi paylaşımını ve inovasyonu destekliyoruz.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
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
              height: SizeHelper.safeContainerHeight(context, preferredHeight: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1A2332),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2196F3),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1A2332),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
                    );
                  },
                  cacheWidth: 800,
                  cacheHeight: 600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsAlertSection extends StatelessWidget {
  const _AnnouncementsAlertSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirestoreProvider>(
      builder: (context, firestoreProvider, _) => StreamBuilder<List<AnnouncementData>>(
        stream: firestoreProvider.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final announcements = snapshot.data!;
          
          // Sadece son 3 duyuruyu göster
          final recentAnnouncements = announcements.take(3).toList();

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A0E17),
            ),
            padding: SizeHelper.safePadding(
              context: context,
              horizontal: 60,
              vertical: 20,
            ),
            child: Column(
              children: recentAnnouncements.map((announcement) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: announcement.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: announcement.color.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/announcements');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: announcement.color,
                              size: SizeHelper.safeSize(value: 28, min: 20, max: 36, context: 'Alert icon size'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: announcement.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _getTypeDisplayName(announcement.type),
                                          style: TextStyle(
                                            color: announcement.color,
                                            fontSize: SizeHelper.safeFontSize(context, preferredSize: 12),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    announcement.eventName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        announcement.date,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          announcement.address,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: SizeHelper.safeFontSize(context, preferredSize: 13),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: announcement.color,
                              size: SizeHelper.safeSize(value: 18, min: 14, max: 24, context: 'Arrow icon size'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'bölüm':
        return 'Bölüm Duyurusu';
      case 'etkinlik':
        return 'Etkinlik Duyurusu';
      case 'topluluk':
        return 'Topluluk Duyurusu';
      default:
        return type;
    }
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0E17),
            const Color(0xFF1A2332).withOpacity(0.5),
          ],
        ),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Hakkımızda',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 42),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: SizeHelper.safeContainerWidth(context, preferredWidth: 800),
            child: Text(
              'Bandırma Onyedi Eylül Üniversitesi Bilgisayar Mühendisliği Topluluğu olarak, teknolojiye tutkulu öğrencileri bir araya getiriyor, bilgi paylaşımını ve inovasyonu destekliyoruz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Daha Fazla Bilgi',
              style: TextStyle(
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A2332),
            const Color(0xFF0A0E17).withOpacity(0.5),
          ],
        ),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Yaklaşan Etkinlikler',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 42),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: SizeHelper.safeContainerWidth(context, preferredWidth: 800),
            child: Text(
              'Teknoloji dünyasında bir adım öne geçmek için etkinliklerimize katılın',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Consumer<FirestoreProvider>(
            builder: (context, firestoreProvider, _) {
              return StreamBuilder<List<EventData>>(
                stream: firestoreProvider.getEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/events'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Tüm Etkinlikleri Gör',
                        style: TextStyle(
                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final events = snapshot.data!.take(3).toList();

                  return Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: events.map((event) {
                          return Container(
                            width: SizeHelper.safeSize(value: 300, min: 250, max: 350, context: 'Event card width'),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0E17),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: event.color.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: event.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    event.type,
                                    style: TextStyle(
                                      color: event.color,
                                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 12),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      event.date,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.white70, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        event.location,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 13),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Tüm Etkinlikleri Gör',
                          style: TextStyle(
                            fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0E17),
            const Color(0xFF1A2332).withOpacity(0.5),
          ],
        ),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Ekibimiz',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 42),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: SizeHelper.safeContainerWidth(context, preferredWidth: 800),
            child: Text(
              'Topluluğumuzun kalbi burada atıyor. Ekibimizi tanıyın ve birlikte neler başardığımızı keşfedin',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Consumer<FirestoreProvider>(
            builder: (context, firestoreProvider, _) {
              return StreamBuilder<List<TeamData>>(
                stream: firestoreProvider.getTeams(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/team'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Ekibi Gör',
                        style: TextStyle(
                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final teams = snapshot.data!.take(3).toList();

                  return Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: teams.map((team) {
                          return Container(
                            width: SizeHelper.safeSize(value: 250, min: 200, max: 300, context: 'Team card width'),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2332),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.groups,
                                    color: Color(0xFF2196F3),
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  team.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (team.description != null && team.description!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    team.description!,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 13),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/team'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Tüm Ekibi Gör',
                          style: TextStyle(
                            fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SponsorsSection extends StatelessWidget {
  const _SponsorsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A2332),
            const Color(0xFF0A0E17).withOpacity(0.5),
          ],
        ),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Sponsorlarımız',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 42),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: SizeHelper.safeContainerWidth(context, preferredWidth: 800),
            child: Text(
              'Bizi destekleyen değerli sponsorlarımıza teşekkür ederiz',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Consumer<FirestoreProvider>(
            builder: (context, firestoreProvider, _) {
              return StreamBuilder<List<SponsorData>>(
                stream: firestoreProvider.getSponsors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/sponsor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Sponsorları Gör',
                        style: TextStyle(
                          fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final sponsors = snapshot.data!.take(6).toList();

                  return Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: sponsors.map((sponsor) {
                          return Container(
                            width: SizeHelper.safeSize(value: 180, min: 150, max: 220, context: 'Sponsor card width'),
                            height: SizeHelper.safeSize(value: 150, min: 120, max: 180, context: 'Sponsor card height'),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0E17),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sponsor.tierColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: sponsor.logoUrl.isNotEmpty
                                      ? Image.network(
                                          sponsor.logoUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.business,
                                              color: sponsor.tierColor,
                                              size: 40,
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.business,
                                          color: sponsor.tierColor,
                                          size: 40,
                                        ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  sponsor.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/sponsor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Tüm Sponsorları Gör',
                          style: TextStyle(
                            fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E17),
      ),
      padding: SizeHelper.safePadding(
        context: context,
        horizontal: 60,
        vertical: 50,
      ),
      child: Column(
        children: [
          Text(
            '© 2025 Bilgisayar Mühendisliği Topluluğu. Tüm hakları saklıdır.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

