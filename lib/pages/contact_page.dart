import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../services/firestore_service.dart';
import '../utils/size_helper.dart';

// Conditional import for web and non-web platforms
import 'map_helper_stub.dart'
    if (dart.library.html) 'map_helper_web.dart'
    as map_helper;

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/contact'),
            _ContactContent(),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _ContactContent extends StatelessWidget {
  final _firestoreService = FirestoreService();

  List<SocialMedia> _parseSocialMedia(List<dynamic>? socialMediaData) {
    if (socialMediaData == null || socialMediaData.isEmpty) {
      // Admin henüz sosyal medya eklemediyse hiçbir şey gösterme
      return [];
    }

    return socialMediaData.map((item) {
      final data = item as Map<String, dynamic>;
      return SocialMedia(
        name: data['name'] ?? '',
        icon: _getIconData(data['icon'] ?? 'link'),
        url: data['url'] ?? '',
        color: _parseColor(data['color'] ?? '#2196F3'),
      );
    }).toList();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'instagram':
        return Icons.camera_alt;
      case 'linkedin':
        return Icons.business;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'tiktok':
        return Icons.music_note;
      case 'whatsapp':
        return Icons.chat;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'business':
        return Icons.business;
      case 'play_circle_filled':
        return Icons.play_circle_filled;
      case 'music_note':
        return Icons.music_note;
      case 'link':
        return Icons.link;
      case 'facebook':
        return Icons.facebook;
      case 'language':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık Bölümü
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.contact_mail,
                        color: Color(0xFF2196F3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bize Ulaşın',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'İletişim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeHelper.safeFontSize(
                      context,
                      preferredSize: isMobile ? 40 : 56,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
                  child: const Text(
                    'Bizimle iletişime geçin ve sorularınızı bize iletin',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),

          // İletişim Bilgileri ve Sosyal Medya Grid
          StreamBuilder<Map<String, dynamic>>(
            stream: _firestoreService.getContactSettingsStream(),
            builder: (context, snapshot) {
              final email = snapshot.data?['email'] ?? '';
              final socialMediaList = _parseSocialMedia(
                snapshot.data?['socialMedia'],
              );

              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İletişim Bilgileri
                        const Text(
                          'İletişim Bilgileri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (email.isNotEmpty)
                          _ContactInfoCard(
                            icon: Icons.email,
                            title: 'E-posta',
                            content: email,
                            color: const Color(0xFF2196F3),
                            onTap: () async {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',
                                path: email,
                              );
                              if (await canLaunchUrl(emailUri)) {
                                await launchUrl(emailUri);
                              }
                            },
                          ),
                        if (email.isNotEmpty) const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        StreamBuilder<Map<String, dynamic>>(
                          stream: _firestoreService.getSiteSettingsStream(),
                          builder: (context, siteSnapshot) {
                            final address = siteSnapshot.data?['address'] ?? '';
                            if (address.isEmpty) return const SizedBox.shrink();
                            
                            return _ContactInfoCard(
                              icon: Icons.location_on,
                              title: 'Adres',
                              content: address,
                              color: const Color(0xFFF44336),
                              onTap: () async {
                                final Uri mapUri = Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                                );
                                if (await canLaunchUrl(mapUri)) {
                                  await launchUrl(
                                    mapUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        // Sosyal Medya
                        const Text(
                          'Sosyal Medya Hesaplarımız',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bizi sosyal medyada takip edin ve güncel haberlerden haberdar olun',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: SizeHelper.safeCrossAxisCount(context, preferredCount: 2),
                                crossAxisSpacing: SizeHelper.safeSize(value: 16, min: 8, max: 32, context: 'Grid spacing'),
                                mainAxisSpacing: SizeHelper.safeSize(value: 16, min: 8, max: 32, context: 'Grid spacing'),
                                childAspectRatio: SizeHelper.safeSize(value: 1.1, min: 0.8, max: 1.5, context: 'Grid aspect ratio'),
                              ),
                          itemCount: socialMediaList.length,
                          itemBuilder: (context, index) {
                            return _SocialMediaCard(socialMediaList[index]);
                          },
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sol Taraf - İletişim Bilgileri
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İletişim Bilgileri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              if (email.isNotEmpty)
                                _ContactInfoCard(
                                  icon: Icons.email,
                                  title: 'E-posta',
                                  content: email,
                                  color: const Color(0xFF2196F3),
                                  onTap: () async {
                                    final Uri emailUri = Uri(
                                      scheme: 'mailto',
                                      path: email,
                                    );
                                    if (await canLaunchUrl(emailUri)) {
                                      await launchUrl(emailUri);
                                    }
                                  },
                                ),
                              if (email.isNotEmpty) const SizedBox(height: 20),
                              StreamBuilder<Map<String, dynamic>>(
                                stream: _firestoreService.getSiteSettingsStream(),
                                builder: (context, siteSnapshot) {
                                  final address = siteSnapshot.data?['address'] ?? '';
                                  if (address.isEmpty) return const SizedBox.shrink();
                                  
                                  return _ContactInfoCard(
                                    icon: Icons.location_on,
                                    title: 'Adres',
                                    content: address,
                                    color: const Color(0xFFF44336),
                                    onTap: () async {
                                      final Uri mapUri = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                                      );
                                      if (await canLaunchUrl(mapUri)) {
                                        await launchUrl(
                                          mapUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Sağ Taraf - Sosyal Medya
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sosyal Medya Hesaplarımız',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bizi sosyal medyada takip edin ve güncel haberlerden haberdar olun',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                                ),
                              ),
                              const SizedBox(height: 30),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: SizeHelper.safeCrossAxisCount(context, preferredCount: 2),
                                crossAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
                                mainAxisSpacing: SizeHelper.safeSize(value: 20, min: 10, max: 40, context: 'Grid spacing'),
                                childAspectRatio: SizeHelper.safeSize(value: 1.2, min: 0.8, max: 1.5, context: 'Grid aspect ratio'),
                              ),
                                itemCount: socialMediaList.length,
                                itemBuilder: (context, index) {
                                  return _SocialMediaCard(
                                    socialMediaList[index],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
          SizedBox(height: isMobile ? 40 : 60),

          // Harita veya Ekstra Bilgi Bölümü
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.message,
                              color: Color(0xFF2196F3),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Mesaj Gönderin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Sorularınız, önerileriniz veya iş birliği teklifleriniz için bizimle iletişime geçebilirsiniz. Size en kısa sürede dönüş yapacağız.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final contactData = await _firestoreService.getContactSettings();
                            final email = contactData['email'] ?? '';
                            if (email.isEmpty) return;
                            
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: email,
                              query: 'subject=İletişim Formu',
                            );
                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'E-posta Gönder',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: SizeHelper.safeInfinity(context, isWidth: true),
                        height: SizeHelper.safeSize(value: 200, min: 150, max: 400, context: 'Map height'),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1929),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? const _GoogleMapWidget()
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        color: Colors.white54,
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Harita',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2196F3,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.message,
                                    color: Color(0xFF2196F3),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Mesaj Gönderin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 24),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Sorularınız, önerileriniz veya iş birliği teklifleriniz için bizimle iletişime geçebilirsiniz. Size en kısa sürede dönüş yapacağız.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () async {
                                final Uri emailUri = Uri(
                                  scheme: 'mailto',
                                  path: 'info@bmt.edu.tr',
                                  query: 'subject=İletişim Formu',
                                );
                                if (await canLaunchUrl(emailUri)) {
                                  await launchUrl(emailUri);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.email, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'E-posta Gönder',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      Container(
                        width: SizeHelper.safeSize(value: 300, min: 200, max: 500, context: 'Map width'),
                        height: SizeHelper.safeSize(value: 200, min: 150, max: 400, context: 'Map height'),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1929),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? const _GoogleMapWidget()
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        color: Colors.white54,
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Harita',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class SocialMedia {
  final String name;
  final IconData icon;
  final String url;
  final Color color;

  SocialMedia({
    required this.name,
    required this.icon,
    required this.url,
    required this.color,
  });
}

class _SocialMediaCard extends StatelessWidget {
  final SocialMedia socialMedia;

  const _SocialMediaCard(this.socialMedia);

  @override
  Widget build(BuildContext context) {
    final hasUrl = socialMedia.url.isNotEmpty;
    
    return InkWell(
      onTap: hasUrl ? () async {
        final Uri uri = Uri.parse(socialMedia.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } : null, // URL boşsa tıklanamaz
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: socialMedia.color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: socialMedia.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                socialMedia.icon,
                color: socialMedia.color,
                size: SizeHelper.safeSize(value: 48, min: 32, max: 64, context: 'Social media icon size'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              socialMedia.name,
              style: TextStyle(
                color: hasUrl ? Colors.white : Colors.white54, // URL boşsa daha soluk
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!hasUrl) // URL boşsa bilgi metni göster
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Link eklenmedi',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: SizeHelper.safeFontSize(context, preferredSize: 10),
                  ),
                ),
              ),
            if (hasUrl) ...[
              const SizedBox(height: 8),
              const Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final VoidCallback onTap;

  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMapWidget extends StatelessWidget {
  const _GoogleMapWidget();

  @override
  Widget build(BuildContext context) {
    return map_helper.createMapWidget();
  }
}
