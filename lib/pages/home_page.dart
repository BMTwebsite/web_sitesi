import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/firestore_provider.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/image_viewer_dialog.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: HeaderSliverDelegate(
              child: const Header(currentRoute: '/'),
              context: context,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const _AnnouncementsAlertSection(),
                const _HeroSection(),
                const _HomeSectionsList(),
                const _StatisticsSection(),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirestoreProvider>(
      builder: (context, firestoreProvider, _) => StreamBuilder<List<HomeSectionData>>(
        stream: firestoreProvider.getHomeSections(),
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
            print('❌ Home sections hatası: ${snapshot.error}');
            // Hata durumunda varsayılan içeriği göster
            return _buildDefaultHeroSection(context);
          }

          final sections = snapshot.data ?? [];
          // Sadece görünür olanları filtrele ve sırala
          final visibleSections = sections.where((s) => s.visible).toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          if (visibleSections.isEmpty) {
            // Hiç bölüm yoksa varsayılan içeriği göster
            return _buildDefaultHeroSection(context);
          }

          // İlk bölümü hero section olarak göster
          return _buildHeroSectionFromData(context, visibleSections.first);
        },
      ),
    );
  }

  Widget _buildDefaultHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);
    
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
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 60),
        vertical: isMobile ? 24 : (isTablet ? 40 : 80),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 1000;
          
          if (isSmallScreen) {
            // Küçük ekranlar için column layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : (isTablet ? 12 : 16),
                    vertical: isMobile ? 5 : (isTablet ? 6 : 8),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cable,
                        color: const Color(0xFF2196F3),
                        size: SizeHelper.clampFontSize(screenWidth, 14, 17, 20),
                      ),
                      SizedBox(width: isMobile ? 5 : 8),
                      Flexible(
                        child: Text(
                          'Bilgisayar Mühendisliği Topluluğu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeHelper.clampFontSize(screenWidth, 11, 12, 14),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : (isTablet ? 24 : 40)),
                Text(
                  'Kodla Geleceği',
                  style: TextStyle(
                    color: const Color(0xFF2196F3),
                    fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tasarla Yarını',
                  style: TextStyle(
                    color: const Color(0xFFF44336),
                    fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Birlikte Başaralım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 30)),
                Text(
                  'Bilgisayar Mühendisliği Topluluğu olarak, teknolojiye tutkulu öğrencileri bir araya getiriyor, bilgi paylaşımını ve inovasyonu destekliyoruz.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 18),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 16 : (isTablet ? 24 : 40)),
                Container(
                  height: isMobile ? 200 : (isTablet ? 300 : 400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF1A2332),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      ImageViewerDialog.show(
                        context,
                        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop',
                      );
                    },
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
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          
          // Büyük ekranlar için row layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : (isTablet ? 12 : 16),
                        vertical: isMobile ? 5 : (isTablet ? 6 : 8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2332),
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cable,
                            color: const Color(0xFF2196F3),
                            size: SizeHelper.clampFontSize(screenWidth, 14, 17, 20),
                          ),
                          SizedBox(width: isMobile ? 5 : 8),
                          Text(
                            'Bilgisayar Mühendisliği Topluluğu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeHelper.clampFontSize(screenWidth, 11, 12, 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                SizedBox(height: isMobile ? 16 : (isTablet ? 24 : 40)),
                Text(
                  'Kodla Geleceği',
                  style: TextStyle(
                    color: const Color(0xFF2196F3),
                    fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tasarla Yarını',
                  style: TextStyle(
                    color: const Color(0xFFF44336),
                    fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Birlikte Başaralım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 30)),
                Text(
                  'Bilgisayar Mühendisliği Topluluğu olarak, teknolojiye tutkulu öğrencileri bir araya getiriyor, bilgi paylaşımını ve inovasyonu destekliyoruz.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 18),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                  ],
                ),
              ),
              SizedBox(width: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Spacing')),
              Expanded(
                flex: 1,
                child: Container(
                  height: isMobile ? 300 : (isTablet ? 450 : 600),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF1A2332),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      ImageViewerDialog.show(
                        context,
                        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop',
                      );
                    },
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
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSectionFromData(BuildContext context, HomeSectionData section) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);
    
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
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 60),
        vertical: isMobile ? 24 : (isTablet ? 40 : 80),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 1000;
          
          if (isSmallScreen) {
            // Küçük ekranlar için column layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 30)),
                if (section.title != null && section.title!.isNotEmpty)
                  Text(
                    section.title!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                if (section.description != null && section.description!.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 30)),
                  Text(
                    section.description!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 18),
                      height: 1.5,
                    ),
                  ),
                ],
                if (section.images.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 16 : (isTablet ? 24 : 40)),
                  if (section.images.length == 1)
                    Container(
                      height: isMobile ? 200 : (isTablet ? 300 : 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF1A2332),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          ImageViewerDialog.show(context, section.images[0]);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            section.images[0],
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
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: section.images.map((imageUrl) {
                        return GestureDetector(
                          onTap: () {
                            ImageViewerDialog.show(context, imageUrl);
                          },
                          child: Container(
                            width: isMobile 
                                ? (MediaQuery.of(context).size.width - 32 - 12) / 2
                                : (isTablet ? 200 : 250),
                            height: isMobile ? 150 : (isTablet ? 200 : 250),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF1A2332),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                imageUrl,
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
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ],
            );
          }
          
          // Büyük ekranlar için row layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isMobile ? 16 : (isTablet ? 24 : 40)),
                    if (section.title != null && section.title!.isNotEmpty)
                      Text(
                        section.title!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 22, 36, 56),
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    if (section.description != null && section.description!.isNotEmpty) ...[
                      SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 30)),
                      Text(
                        section.description!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 18),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (section.images.isNotEmpty) ...[
                SizedBox(width: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Spacing')),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: isMobile ? 300 : (isTablet ? 450 : 600),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1A2332),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ImageViewerDialog.show(context, section.images[0]);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          section.images[0],
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
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HomeSectionsList extends StatelessWidget {
  const _HomeSectionsList();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirestoreProvider>(
      builder: (context, firestoreProvider, _) => StreamBuilder<List<HomeSectionData>>(
        stream: firestoreProvider.getHomeSections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final sections = snapshot.data ?? [];
          // Sadece görünür olanları filtrele ve sırala (ilk bölüm hariç çünkü o hero section'da gösteriliyor)
          final visibleSections = sections.where((s) => s.visible).toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          if (visibleSections.length <= 1) {
            // Sadece hero section varsa veya hiç yoksa, burada bir şey gösterme
            return const SizedBox.shrink();
          }

          // İlk bölümü atla (hero section'da gösteriliyor)
          final otherSections = visibleSections.skip(1).toList();

          return Column(
            children: otherSections.map((section) {
              return _buildSectionWidget(context, section);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSectionWidget(BuildContext context, HomeSectionData section) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = SizeHelper.isMobile(context);
    final isTablet = SizeHelper.isTablet(context);
    
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
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 60),
        vertical: isMobile ? 24 : (isTablet ? 40 : 80),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 1000;
          
          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.title != null && section.title!.isNotEmpty)
                  Text(
                    section.title!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.clampFontSize(screenWidth, 20, 28, 36),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (section.description != null && section.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    section.description!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 18),
                      height: 1.5,
                    ),
                  ),
                ],
                if (section.images.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    height: isMobile ? 200 : (isTablet ? 300 : 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1A2332),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ImageViewerDialog.show(context, section.images[0]);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          section.images[0],
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
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (section.title != null && section.title!.isNotEmpty)
                      Text(
                        section.title!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 20, 28, 36),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (section.description != null && section.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        section.description!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 18),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (section.images.isNotEmpty) ...[
                SizedBox(width: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Spacing')),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: isMobile ? 300 : (isTablet ? 450 : 600),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1A2332),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ImageViewerDialog.show(context, section.images[0]);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          section.images[0],
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
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
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
        stream: firestoreProvider.getAnnouncements(limit: 3),
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
            padding: EdgeInsets.symmetric(
              horizontal: SizeHelper.isMobile(context) ? 16 : (SizeHelper.isTablet(context) ? 24 : 40),
              vertical: 12,
            ),
            child: Column(
              children: recentAnnouncements.map((announcement) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: announcement.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: announcement.color.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/announcements');
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: EdgeInsets.all(SizeHelper.isMobile(context) ? 10 : (SizeHelper.isTablet(context) ? 12 : 14)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: announcement.color,
                              size: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 18, 20, 22),
                            ),
                            SizedBox(width: SizeHelper.isMobile(context) ? 8 : (SizeHelper.isTablet(context) ? 10 : 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width < 768 ? 5 : (MediaQuery.of(context).size.width < 1024 ? 6 : 8),
                                          vertical: MediaQuery.of(context).size.width < 768 ? 2 : (MediaQuery.of(context).size.width < 1024 ? 3 : 4),
                                        ),
                                        decoration: BoxDecoration(
                                          color: announcement.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          _getTypeDisplayName(announcement.type),
                                          style: TextStyle(
                                            color: announcement.color,
                                            fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 9, 10, 11),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    announcement.eventName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 13, 14, 15),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.white70,
                                            size: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 12, 13, 14),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              announcement.date,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 11, 12, 13),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white70,
                                            size: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 12, 13, 14),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              announcement.address,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 11, 12, 13),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: SizeHelper.isMobile(context) ? 4 : 6),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: announcement.color,
                              size: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 12, 14, 16),
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

// Counter animasyonlu widget
class _AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final TextStyle? textStyle;

  const _AnimatedCounter({
    required this.targetValue,
    this.textStyle,
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.targetValue.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _animation.addListener(() {
      setState(() {
        _currentValue = _animation.value.round();
      });
    });

    // Sayfa yüklendiğinde animasyonu başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(
        begin: _currentValue.toDouble(),
        end: widget.targetValue.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentValue.toString(),
      style: widget.textStyle,
    );
  }
}

// Statistics Section with lazy loading
class _StatisticsSection extends StatefulWidget {
  const _StatisticsSection();

  @override
  State<_StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<_StatisticsSection> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    // Defer loading statistics until after initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _shouldLoad = true;
        });
      }
    });
  }

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
            const Color(0xFF0A0E17),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeHelper.isMobile(context) ? 16 : (SizeHelper.isTablet(context) ? 32 : 60),
        vertical: SizeHelper.isMobile(context) ? 40 : (SizeHelper.isTablet(context) ? 60 : 80),
      ),
      child: _shouldLoad
          ? Consumer<FirestoreProvider>(
              builder: (context, firestoreProvider, _) => StreamBuilder<Map<String, dynamic>>(
                stream: firestoreProvider.firestoreService.getStatisticsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final statistics = snapshot.data ?? {
                    'memberCount': 0,
                    'eventCount': 0,
                    'projectCount': 0,
                    'workshopCount': 0,
                    'memberCountVisible': true,
                    'eventCountVisible': true,
                    'projectCountVisible': true,
                    'workshopCountVisible': true,
                  };

                  final memberCount = (statistics['memberCount'] as num?)?.toInt() ?? 0;
                  final eventCount = (statistics['eventCount'] as num?)?.toInt() ?? 0;
                  final projectCount = (statistics['projectCount'] as num?)?.toInt() ?? 0;
                  final workshopCount = (statistics['workshopCount'] as num?)?.toInt() ?? 0;

                  final memberCountVisible = statistics['memberCountVisible'] ?? true;
                  final eventCountVisible = statistics['eventCountVisible'] ?? true;
                  final projectCountVisible = statistics['projectCountVisible'] ?? true;
                  final workshopCountVisible = statistics['workshopCountVisible'] ?? true;

                  // Sadece visible olan istatistikleri filtrele
                  final statCards = <Widget>[];
                  
                  if (memberCountVisible) {
                    statCards.add(
                      _StatCard(
                        icon: Icons.people,
                        label: 'Üye Sayısı',
                        value: memberCount,
                        color: const Color(0xFF2196F3),
                      ),
                    );
                  }
                  
                  if (eventCountVisible) {
                    statCards.add(
                      _StatCard(
                        icon: Icons.event,
                        label: 'Yapılan Etkinlik',
                        value: eventCount,
                        color: const Color(0xFFF44336),
                      ),
                    );
                  }
                  
                  if (projectCountVisible) {
                    statCards.add(
                      _StatCard(
                        icon: Icons.code,
                        label: 'Proje Sayısı',
                        value: projectCount,
                        color: const Color(0xFF4CAF50),
                      ),
                    );
                  }
                  
                  if (workshopCountVisible) {
                    statCards.add(
                      _StatCard(
                        icon: Icons.school,
                        label: 'Workshop Sayısı',
                        value: workshopCount,
                        color: const Color(0xFFFF9800),
                      ),
                    );
                  }

                  // Eğer hiçbir istatistik gösterilmiyorsa bölümü gizle
                  if (statCards.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final screenWidth = MediaQuery.of(context).size.width;
                  final isMobile = screenWidth < 768;
                  final isTablet = screenWidth >= 768 && screenWidth < 1024;
                  
                  return Column(
                    children: [
                      Text(
                        'Sayılarla BMT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 24, 32, 42),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : (isTablet ? 16 : 20)),
                      SizedBox(
                        width: isMobile ? double.infinity : (isTablet ? screenWidth * 0.8 : 800),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                          child: Text(
                            'Topluluğumuzun başarılarını rakamlarla keşfedin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: SizeHelper.clampFontSize(screenWidth, 14, 16, 18),
                              height: 1.6,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 30 : (isTablet ? 40 : 60)),
                      Wrap(
                        spacing: isMobile ? 16 : (isTablet ? 20 : 30),
                        runSpacing: isMobile ? 16 : (isTablet ? 20 : 30),
                        alignment: WrapAlignment.center,
                        children: statCards,
                      ),
                    ],
                  );
                },
              ),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : (isTablet ? 220 : 280),
        minWidth: isMobile ? 0 : 200,
      ),
      child: Container(
        width: isMobile ? double.infinity : null,
        padding: EdgeInsets.all(isMobile ? 20 : (isTablet ? 24 : 32)),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 14 : 16)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: SizeHelper.clampFontSize(screenWidth, 28, 36, 48),
              ),
            ),
            SizedBox(height: isMobile ? 16 : (isTablet ? 20 : 24)),
            _AnimatedCounter(
              targetValue: value,
              textStyle: TextStyle(
                color: color,
                fontSize: SizeHelper.clampFontSize(screenWidth, 32, 40, 48),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.clampFontSize(screenWidth, 13, 14, 16),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


