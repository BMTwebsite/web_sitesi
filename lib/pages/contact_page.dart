import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';

// Conditional import for web and non-web platforms
import 'map_helper_stub.dart'
    if (dart.library.html) 'map_helper_web.dart'
    as map_helper;

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final List<SocialMedia> socialMediaList = [
    SocialMedia(
      name: 'Instagram',
      icon: Icons.camera_alt,
      url: 'https://www.instagram.com/banubmt?igsh=MmtvemV2YWtqYzVu',
      color: const Color(0xFFE4405F),
    ),
    SocialMedia(
      name: 'LinkedIn',
      icon: Icons.business,
      url: 'https://www.linkedin.com/company/banubmt/',
      color: const Color(0xFF0077B5),
    ),
    SocialMedia(
      name: 'YouTube',
      icon: Icons.play_circle_filled,
      url: 'https://youtube.com/@banubmt?si=w6Qi4NEKYoOmUZmz',
      color: const Color(0xFFFF0000),
    ),
    SocialMedia(
      name: 'TikTok',
      icon: Icons.music_note,
      url: 'https://www.tiktok.com',
      color: const Color(0xFF000000),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
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
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.contact_mail,
                        color: const Color(0xFF2196F3),
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
                const Text(
                  'İletişim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bizimle iletişime geçin ve sorularınızı bize iletin',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),

          // İletişim Bilgileri ve Sosyal Medya Grid
          Row(
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
                    _ContactInfoCard(
                      icon: Icons.email,
                      title: 'E-posta',
                      content: 'info@bmt.edu.tr',
                      color: const Color(0xFF2196F3),
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'info@bmt.edu.tr',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _ContactInfoCard(
                      icon: Icons.location_on,
                      title: 'Adres',
                      content:
                          'Bandırma Onyedi Eylül Üniversitesi\nBilgisayar Mühendisliği ',
                      color: const Color(0xFFF44336),
                      onTap: () {},
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
                    const Text(
                      'Bizi sosyal medyada takip edin ve güncel haberlerden haberdar olun',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: socialMediaList.length,
                      itemBuilder: (context, index) {
                        return _SocialMediaCard(socialMediaList[index]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Harita veya Ekstra Bilgi Bölümü
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
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
                              color: const Color(0xFF2196F3).withOpacity(0.2),
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
                              fontSize: 24,
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
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1929),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
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

class _TikTokGlitchIcon extends StatelessWidget {
  final double size;

  const _TikTokGlitchIcon({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cyan shadow (top-left)
          Positioned(
            top: -2,
            left: -2,
            child: Icon(
              Icons.music_note,
              color: const Color(0xFF00F2EA),
              size: size,
            ),
          ),
          // Red shadow (bottom-right)
          Positioned(
            bottom: -2,
            right: -2,
            child: Icon(
              Icons.music_note,
              color: const Color(0xFFFF0050),
              size: size,
            ),
          ),
          // White main icon
          Icon(Icons.music_note, color: Colors.white, size: size),
        ],
      ),
    );
  }
}

class _YouTubeIcon extends StatelessWidget {
  final double size;

  const _YouTubeIcon({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.2,
      height: size * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.5, size * 0.5),
          painter: _PlayButtonPainter(),
        ),
      ),
    );
  }
}

class _PlayButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // Üçgen çizmek için path kullanıyoruz
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.9, size.height * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LinkedInIcon extends StatelessWidget {
  final double size;

  const _LinkedInIcon({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0077B5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.65,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _InstagramIcon extends StatelessWidget {
  final double size;

  const _InstagramIcon({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF833AB4), // Mor
            Color(0xFFE1306C), // Pembe
            Color(0xFFF77737), // Turuncu
            Color(0xFFFCAF45), // Sarı
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.7, size * 0.7),
          painter: _CameraIconPainter(),
        ),
      ),
    );
  }
}

class _CameraIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Kamera gövdesi (yuvarlatılmış dikdörtgen)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.15,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.6,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Ana lens (büyük daire)
    final lensPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.2,
      lensPaint,
    );

    // Viewfinder/flash (küçük daire - sağ üst)
    final viewfinderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      size.width * 0.08,
      viewfinderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SocialMediaCard extends StatelessWidget {
  final SocialMedia socialMedia;

  const _SocialMediaCard(this.socialMedia);

  Widget _getSocialMediaIcon(String name) {
    switch (name) {
      case 'TikTok':
        return const _TikTokGlitchIcon(size: 32);
      case 'YouTube':
        return const _YouTubeIcon(size: 32);
      case 'LinkedIn':
        return const _LinkedInIcon(size: 32);
      case 'Instagram':
        return const _InstagramIcon(size: 36);
      default:
        return Icon(socialMedia.icon, color: socialMedia.color, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(socialMedia.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: socialMedia.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: _getSocialMediaIcon(socialMedia.name),
            ),
            const SizedBox(height: 16),
            Text(
              socialMedia.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
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
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
