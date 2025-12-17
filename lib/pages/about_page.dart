import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../utils/size_helper.dart';
import '../providers/firestore_provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: HeaderSliverDelegate(
              child: const Header(currentRoute: '/about'),
              context: context,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
            
            Container(
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
                horizontal: MediaQuery.of(context).size.width < 768 ? 16 : (MediaQuery.of(context).size.width < 1024 ? 32 : 60),
                vertical: MediaQuery.of(context).size.width < 768 ? 40 : (MediaQuery.of(context).size.width < 1024 ? 50 : 60),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- BAŞLIK ---
                  Text(
                    'Biz Kimiz & Ne Yapıyoruz?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.clampFontSize(MediaQuery.of(context).size.width, 24, 32, 42),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).size.width < 768 ? 30 : (MediaQuery.of(context).size.width < 1024 ? 40 : 60)),

                  // --- İÇERİK ---
                  _buildAboutContent(),
                ],
              ),
            ),

                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- İÇERİK: HAKKIMIZDA ---
  Widget _buildAboutContent() {
    return Consumer<FirestoreProvider>(
      builder: (context, firestoreProvider, _) {
        return StreamBuilder<List<AboutSectionData>>(
          stream: firestoreProvider.getAboutSections(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    'Hata: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final sections = snapshot.data ?? [];
            final visibleSections = sections.where((s) => s.visible).toList();

            if (visibleSections.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'Henüz içerik eklenmemiş.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 768;
            final isTablet = screenWidth >= 768 && screenWidth < 1024;

            return Column(
              key: const ValueKey('About'),
              children: [
                // Ana açıklama (ilk section'dan alınabilir veya site settings'ten)
                if (visibleSections.isNotEmpty) ...[
                  SizedBox(
                    width: isMobile ? double.infinity : (isTablet ? screenWidth * 0.9 : 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                      child: Text(
                        'Teknoloji tutkumuzu akademik bilgiyle birleştiriyor, Bandırma\'dan dünyaya açılan projeler geliştiriyoruz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: SizeHelper.clampFontSize(screenWidth, 14, 16, 18),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : (isTablet ? 50 : 80)),
                ],
                // Sections
                ...visibleSections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  Color accentColor;
                  try {
                    accentColor = Color(int.parse(section.accentColor.replaceFirst('#', '0xFF')));
                  } catch (e) {
                    accentColor = const Color(0xFF2196F3);
                  }
                  
                  return Column(
                    children: [
                      _InfoSection(
                        title: section.title,
                        subtitle: section.subtitle,
                        description: section.description,
                        imageUrl: section.imageUrl,
                        isImageRight: section.isImageRight,
                        accentColor: accentColor,
                      ),
                      if (index < visibleSections.length - 1)
                        SizedBox(height: MediaQuery.of(context).size.width < 768 ? 30 : (MediaQuery.of(context).size.width < 1024 ? 40 : 60)),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

}

// --- BİLGİ KARTI (Sabit İçerik) ---
class _InfoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final bool isImageRight;
  final Color accentColor;

  const _InfoSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.isImageRight,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    List<Widget> children = [
      Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : (isTablet ? 30 : 40)),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: SizeHelper.clampFontSize(screenWidth, 11, 13, 14),
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeHelper.clampFontSize(screenWidth, 22, 28, 32),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: SizeHelper.clampFontSize(screenWidth, 13, 15, 16),
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: isMobile ? 0 : (isTablet ? 20 : 40)),
      Expanded(
        flex: 1,
        child: Container(
          height: isMobile ? 250 : (isTablet ? 300 : 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF1A2332),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: accentColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1A2332),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: isMobile ? 48 : 64,
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(
                          'Görsel yüklenemedi',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ];

    if (!isImageRight) {
      children = children.reversed.toList();
    }

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}