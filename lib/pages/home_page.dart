import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/firestore_provider.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../widgets/image_viewer_dialog.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web show platformViewRegistry;
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
      final search = html.window.location.search ?? '';
      
      String? token;
      
      // Yöntem 1: Hash'ten token parse et
      if (hash.isNotEmpty) {
        if (hash.contains('/admin-verify') && hash.contains('token=')) {
          final tokenMatch = RegExp(r'token=([^&#]+)').firstMatch(hash);
          if (tokenMatch != null && tokenMatch.group(1) != null) {
            token = Uri.decodeComponent(tokenMatch.group(1)!);
          }
        }
      }
      
      // Yöntem 2: Search'ten token parse et
      if ((token == null || token.isEmpty) && search.isNotEmpty) {
        try {
          final searchUri = Uri.parse(search);
          token = searchUri.queryParameters['token'];
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ HomePage - Search parse hatası: $e');
          }
        }
      }
      
      // Yöntem 3: Full URL'den token parse et
      if (token == null || token.isEmpty) {
        try {
          final fullUrl = html.window.location.href;
          final fullUri = Uri.parse(fullUrl);
          token = fullUri.queryParameters['token'];
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ HomePage - Full URL parse hatası: $e');
          }
        }
      }
      
      // Token bulunduysa AdminVerifyPage'e yönlendir
      if (token != null && token.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AdminVerifyPage(token: token),
            ),
            (route) => false, // Tüm önceki route'ları temizle
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ HomePage - URL kontrolü hatası: $e');
        print('📚 Stack trace: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // URL kontrolü initState'de yapılıyor, burada tekrar kontrol etmeye gerek yok
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
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
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: SizeHelper.isMobile(context) ? 16 : (SizeHelper.isTablet(context) ? 32 : 60),
                vertical: SizeHelper.isMobile(context) ? 20 : (SizeHelper.isTablet(context) ? 30 : 40),
              ),
              color: const Color(0xFF0A0E17),
              child: Center(
                child: Text(
                  'Bilgisayar Mühendisliği Topluluğu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.clampFontSize(
                      MediaQuery.of(context).size.width,
                      18,
                      24,
                      32,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
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



// Performance: Hero section için skeleton widget - ilk yüklemede daha hızlı görünüm
Widget _buildHeroSkeleton(BuildContext context) {
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
              // Skeleton: Badge
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              // Skeleton: Title lines
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity * 0.8,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity * 0.7,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 20),
              // Skeleton: Description
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 20),
              // Skeleton: Image
              Container(
                height: isMobile ? 200 : 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          );
        }
        
        // Büyük ekranlar için
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton: Badge
                  Container(
                    width: 250,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Skeleton: Title lines
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity * 0.7,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Skeleton: Description
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              flex: 1,
              child: Container(
                height: isMobile ? 300 : 600,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
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
            // Performance: Hafif skeleton ekranı - daha hızlı algılanan performans
            return _buildHeroSkeleton(context);
          }

          if (snapshot.hasError) {
            if (kDebugMode) {
              print('❌ Home sections hatası: ${snapshot.error}');
            }
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
                        // Performance: Optimized loading with progress and cache
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Skeleton placeholder - daha hafif
                          return Container(
                            color: const Color(0xFF1A2332),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF2196F3),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        // Performance: Cache optimization - görsel boyutunu sınırla
                        cacheWidth: SizeHelper.isMobile(context) ? 400 : (SizeHelper.isTablet(context) ? 600 : 800),
                        cacheHeight: SizeHelper.isMobile(context) ? 300 : (SizeHelper.isTablet(context) ? 450 : 600),
                        errorBuilder: (context, error, stackTrace) {
                          // Image.network başarısız olursa HTML img dene
                          try {
                            final imageUrl = 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop';
                            final imageId = 'default_hero_img_${imageUrl.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
                            
                            final imgElement = html.ImageElement()
                              ..src = imageUrl
                              ..style.width = '100%'
                              ..style.height = '100%'
                              ..style.objectFit = 'cover';
                            
                            ui_web.platformViewRegistry.registerViewFactory(
                              imageId,
                              (int viewId) => imgElement,
                            );
                            
                            return HtmlElementView(viewType: imageId);
                          } catch (e) {
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
                          }
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
                        // Performance: Optimized loading with progress and cache
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Skeleton placeholder - daha hafif
                          return Container(
                            color: const Color(0xFF1A2332),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF2196F3),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        // Performance: Cache optimization - görsel boyutunu sınırla
                        cacheWidth: SizeHelper.isMobile(context) ? 400 : (SizeHelper.isTablet(context) ? 600 : 800),
                        cacheHeight: SizeHelper.isMobile(context) ? 300 : (SizeHelper.isTablet(context) ? 450 : 600),
                        errorBuilder: (context, error, stackTrace) {
                          // Image.network başarısız olursa HTML img dene
                          try {
                            final imageUrl = 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop';
                            final imageId = 'default_hero_img_${imageUrl.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
                            
                            final imgElement = html.ImageElement()
                              ..src = imageUrl
                              ..style.width = '100%'
                              ..style.height = '100%'
                              ..style.objectFit = 'cover';
                            
                            ui_web.platformViewRegistry.registerViewFactory(
                              imageId,
                              (int viewId) => imgElement,
                            );
                            
                            return HtmlElementView(viewType: imageId);
                          } catch (e) {
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
                          }
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
    
    // imageOnly tipinde ve tablet/desktop ekranlarda tam ekran yap
    final isLargeScreen = screenWidth >= 768;
    final shouldRemovePadding = section.type == 'imageOnly' && isLargeScreen;
    
    // imageOnly ve büyük ekran için özel container - tam ekran
    if (shouldRemovePadding && section.images.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: _HeroImageSlider(
          images: section.images,
          section: section,
          height: MediaQuery.of(context).size.height,
          fullScreen: true,
        ),
      );
    }
    
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
                  Builder(
                    builder: (context) {
                      if (kDebugMode) {
                        print('🖼️ Hero section images: ${section.images}');
                      }
                      return _HeroImageSlider(
                        images: section.images,
                        section: section,
                        height: isMobile ? 200 : (isTablet ? 300 : 400),
                      );
                    },
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
                  child: Builder(
                    builder: (context) {
                      if (kDebugMode) {
                        print('🖼️ Hero section images (large screen): ${section.images}');
                      }
                      return _HeroImageSlider(
                        images: section.images,
                        section: section,
                        height: isMobile ? 300 : (isTablet ? 450 : 600),
                      );
                    },
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
    final sectionType = section.type;
    
    // Bölüm tipine göre içerik kontrolü
    final showText = (sectionType == 'textOnly' || sectionType == 'both') && 
                     ((section.title != null && section.title!.isNotEmpty) || 
                      (section.description != null && section.description!.isNotEmpty));
    final showImages = (sectionType == 'imageOnly' || sectionType == 'both') && 
                       section.images.isNotEmpty;
    
    // imageOnly tipinde ve büyük ekranlarda padding'i kaldır ve tam ekran yap
    // Tablet ve üzeri ekranlarda tam ekran yap (768px ve üzeri)
    final isLargeScreen = screenWidth >= 768; // Tablet ve üzeri
    final shouldRemovePadding = sectionType == 'imageOnly' && isLargeScreen;
    
    // imageOnly ve büyük ekran için özel container - tam ekran
    if (shouldRemovePadding) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: _buildImageSlider(context, section.images, isMobile, isTablet, section: section, fullScreen: true),
      );
    }
    
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
                if (showText) ...[
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
                    if (section.title != null && section.title!.isNotEmpty)
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
                if (showImages) ...[
                  if (showText) const SizedBox(height: 20),
                  _buildImageSlider(context, section.images, isMobile, isTablet, section: section),
                ],
              ],
            );
          }
          
          // Büyük ekranlar için layout
          if (sectionType == 'imageOnly') {
            // Sadece görsel - küçük ekranlar için normal göster
            return _buildImageSlider(context, section.images, isMobile, isTablet, section: section);
          } else if (sectionType == 'textOnly') {
            // Sadece yazı
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
                  if (section.title != null && section.title!.isNotEmpty)
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
            );
          } else {
            // İkisi birlikte
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
                if (showImages) ...[
                  SizedBox(width: SizeHelper.safeSize(value: 40, min: 20, max: 60, context: 'Spacing')),
                  Expanded(
                    flex: 1,
                    child: _buildImageSlider(context, section.images, isMobile, isTablet, section: section),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  // Image.network helper metodu (hem web hem mobile için)
  Widget _buildWebImageHelper(String imageUrl, BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      headers: const {'Cache-Control': 'max-age=3600'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print('❌ Home Section Image load error for URL: $imageUrl');
          print('❌ Error: $error');
        }
        // Image.network başarısız olursa HTML img dene
        try {
          final imageId = 'section_img_${imageUrl.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
          
          final imgElement = html.ImageElement()
            ..src = imageUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover';
          
          ui_web.platformViewRegistry.registerViewFactory(
            imageId,
            (int viewId) => imgElement,
          );
          
          return HtmlElementView(viewType: imageId);
        } catch (e) {
          // Her iki yöntem de başarısız olursa hata göster
          return Container(
            color: const Color(0xFF1A2332),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
            ),
          );
        }
      },
    );
  }

  // Çoklu görseller için otomatik slider widget'ı
  Widget _buildImageSlider(BuildContext context, List<String> images, bool isMobile, bool isTablet, {HomeSectionData? section, bool fullScreen = false}) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tek görsel varsa normal göster
    if (images.length == 1) {
      final screenHeight = fullScreen ? MediaQuery.of(context).size.height : null;
      return Container(
        height: fullScreen ? screenHeight : (isMobile ? 200 : (isTablet ? 300 : 400)),
        width: fullScreen ? double.infinity : null,
        decoration: BoxDecoration(
          borderRadius: fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
          color: const Color(0xFF1A2332),
        ),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                ImageViewerDialog.show(context, images[0]);
              },
              child: ClipRRect(
                borderRadius: fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
                child: _buildWebImageHelper(images[0], context),
              ),
            ),
          ],
        ),
      );
    }

    // Çoklu görsel varsa slider göster
    return _ImageSliderWidget(
      images: images,
      height: fullScreen ? null : (isMobile ? 200 : (isTablet ? 300 : 400)),
      section: section,
      fullScreen: fullScreen,
    );
  }
}

// Hero section için özel slider widget'ı (admin düzenleme butonu ile)
class _HeroImageSlider extends StatefulWidget {
  final List<String> images;
  final HomeSectionData section;
  final double height;
  final bool fullScreen;

  const _HeroImageSlider({
    required this.images,
    required this.section,
    required this.height,
    this.fullScreen = false,
  });

  @override
  State<_HeroImageSlider> createState() => _HeroImageSliderState();
}

class _HeroImageSliderState extends State<_HeroImageSlider> {
  PageController? _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1) {
      _pageController = PageController();
      // 5 saniyede bir otomatik geçiş
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && widget.images.length > 1 && _pageController != null) {
          final nextIndex = (_currentIndex + 1) % widget.images.length;
          _pageController!.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // Web için Image.network kullan (daha güvenilir ve CORS sorunlarını daha iyi yönetir)
  Widget _buildWebImage(String imageUrl, BuildContext context) {
    // Hem web hem mobile için Image.network kullan
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      headers: const {
        'Cache-Control': 'max-age=3600',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2196F3),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print('❌ Image load error for URL: $imageUrl');
          print('❌ Error: $error');
          print('❌ StackTrace: $stackTrace');
        }
        // Image.network başarısız olursa HTML img dene
        try {
          final imageId = 'hero_img_${imageUrl.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
          
          final imgElement = html.ImageElement()
            ..src = imageUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover';
          
          ui_web.platformViewRegistry.registerViewFactory(
            imageId,
            (int viewId) => imgElement,
          );
          
          return HtmlElementView(viewType: imageId);
        } catch (e) {
          // Her iki yöntem de başarısız olursa hata göster
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
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      width: widget.fullScreen ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: widget.fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
        color: const Color(0xFF1A2332),
      ),
      child: Stack(
        children: [
          widget.images.length == 1
              ? GestureDetector(
                  onTap: () {
                    ImageViewerDialog.show(context, widget.images[0]);
                  },
                  child: ClipRRect(
                    borderRadius: widget.fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
                    child: _buildWebImage(widget.images[0], context),
                  ),
                )
              : PageView.builder(
                  controller: _pageController!,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        ImageViewerDialog.show(context, widget.images[index]);
                      },
                      child: ClipRRect(
                        borderRadius: widget.fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
                        child: _buildWebImage(widget.images[index], context),
                      ),
                    );
                  },
                ),
          // İndikatörler (çoklu görsel varsa)
          if (widget.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          // Sol ok butonu (çoklu görsel varsa)
          if (widget.images.length > 1)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_pageController != null && widget.images.length > 1) {
                        final previousIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length;
                        _pageController!.animateToPage(
                          previousIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Sağ ok butonu (çoklu görsel varsa)
          if (widget.images.length > 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_pageController != null && widget.images.length > 1) {
                        final nextIndex = (_currentIndex + 1) % widget.images.length;
                        _pageController!.animateToPage(
                          nextIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Otomatik slider widget'ı
class _ImageSliderWidget extends StatefulWidget {
  final List<String> images;
  final double? height;
  final HomeSectionData? section;
  final bool fullScreen;

  const _ImageSliderWidget({
    required this.images,
    this.height,
    this.section,
    this.fullScreen = false,
  });

  @override
  State<_ImageSliderWidget> createState() => _ImageSliderWidgetState();
}

class _ImageSliderWidgetState extends State<_ImageSliderWidget> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 5 saniyede bir otomatik geçiş
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final nextIndex = (_currentIndex + 1) % widget.images.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Image.network kullan (hem web hem mobile için)
  Widget _buildWebImage(String imageUrl, BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      headers: const {
        'Cache-Control': 'max-age=3600',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2196F3),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print('❌ Section Image load error for URL: $imageUrl');
          print('❌ Error: $error');
          print('❌ StackTrace: $stackTrace');
        }
        // Image.network başarısız olursa HTML img dene
        try {
          final imageId = 'slider_img_${imageUrl.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
          
          final imgElement = html.ImageElement()
            ..src = imageUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover';
          
          ui_web.platformViewRegistry.registerViewFactory(
            imageId,
            (int viewId) => imgElement,
          );
          
          return HtmlElementView(viewType: imageId);
        } catch (e) {
          // Her iki yöntem de başarısız olursa hata göster
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = widget.fullScreen ? screenHeight : widget.height;
    
    return Container(
      height: containerHeight,
      width: widget.fullScreen ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: widget.fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
        color: const Color(0xFF1A2332),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  ImageViewerDialog.show(context, widget.images[index]);
                },
                child: ClipRRect(
                  borderRadius: widget.fullScreen ? BorderRadius.zero : BorderRadius.circular(20),
                  child: _buildWebImage(widget.images[index], context),
                ),
              );
            },
          ),
          // İndikatörler
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
          // Sol ok butonu (çoklu görsel varsa)
          if (widget.images.length > 1)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final previousIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length;
                      _pageController.animateToPage(
                        previousIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Sağ ok butonu (çoklu görsel varsa)
          if (widget.images.length > 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final nextIndex = (_currentIndex + 1) % widget.images.length;
                      _pageController.animateToPage(
                        nextIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
                            'Topluluğumuzun başarılarını sayılarla keşfedin',
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


