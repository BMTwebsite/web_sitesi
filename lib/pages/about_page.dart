import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../utils/size_helper.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(currentRoute: '/about'),
            
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
              padding: SizeHelper.safePadding(
                context: context,
                horizontal: 60,
                vertical: 60,
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
                      fontSize: SizeHelper.safeFontSize(context, preferredSize: 42),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 60),

                  // --- İÇERİK ---
                  _buildAboutContent(),
                ],
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }

  // --- İÇERİK: HAKKIMIZDA ---
  Widget _buildAboutContent() {
    return Column(
      key: const ValueKey('About'),
      children: [
        SizedBox(
          width: SizeHelper.safeContainerWidth(context, preferredWidth: 600),
          child: Text(
            'Teknoloji tutkumuzu akademik bilgiyle birleştiriyor, Bandırma\'dan dünyaya açılan projeler geliştiriyoruz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 18),
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 80),
        _InfoSection(
          title: 'Bandırma Onyedi Eylül Üniversitesi',
          subtitle: 'Geleceğe Açılan Kapı',
          description: 'Bandırma Onyedi Eylül Üniversitesi, "Geleceğe Açılan Köprü" sloganıyla, bilimsel araştırmaları ve kaliteli eğitimi hedefleyen dinamik bir üniversitedir.\n\nMarmara Denizi\'nin incisi Bandırma\'da yer alan kampüsümüz, öğrencilere sadece akademik bilgi değil, aynı zamanda sosyal ve kültürel gelişim imkanları da sunmaktadır.',
          imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=600&fit=crop',
          isImageRight: true,
          accentColor: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 60),
        _InfoSection(
          title: 'Bilgisayar Mühendisliği',
          subtitle: 'Algoritmaların Gücü',
          description: 'Bilgisayar Mühendisliği bölümü olarak amacımız; analitik düşünebilen, problem çözme yeteneği gelişmiş ve teknolojiyi insanlık yararına kullanabilen mühendisler yetiştirmektir.\n\nYazılım geliştirme, yapay zeka ve siber güvenlik alanlarında sunduğumuz kapsamlı müfredat ile öğrencilerimizi endüstri 4.0\'a hazırlıyoruz.',
          imageUrl: 'https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=800&h=600&fit=crop',
          isImageRight: false,
          accentColor: const Color(0xFFF44336),
        ),
        const SizedBox(height: 80),
        // Destek Bölümü
        _SupportSection(),
        const SizedBox(height: 60),
        // Geri Bildirim Bölümü
        _FeedbackSection(),
      ],
    );
  }

}

// --- DESTEK BÖLÜMÜ ---
class _SupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeHelper.safeContainerWidth(context, preferredWidth: 1000),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Color(0xFF4CAF50),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESTEK',
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Size Nasıl Yardımcı Olabiliriz?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Sorularınız mı var? Yardıma mı ihtiyacınız var? Biz buradayız! Topluluğumuzla ilgili herhangi bir konuda bize ulaşabilirsiniz. Etkinlikler, üyelik, projeler veya genel sorularınız için destek ekibimiz size yardımcı olmaya hazır.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _SupportCard(
                icon: Icons.email,
                title: 'E-posta',
                description: 'info@bmt.edu.tr',
                color: const Color(0xFF2196F3),
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'info@bmt.edu.tr',
                    query: 'subject=Destek Talebi',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
              ),
              _SupportCard(
                icon: Icons.help_outline,
                title: 'Sık Sorulan Sorular',
                description: 'Yaygın soruların cevapları',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  // FAQ sayfasına yönlendirme yapılabilir
                },
              ),
              _SupportCard(
                icon: Icons.chat_bubble_outline,
                title: 'Canlı Destek',
                description: 'Anında yardım alın',
                color: const Color(0xFFF44336),
                onTap: () {
                  // Canlı destek sayfasına yönlendirme yapılabilir
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- GERİ BİLDİRİM BÖLÜMÜ ---
class _FeedbackSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeHelper.safeContainerWidth(context, preferredWidth: 1000),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.feedback,
                  color: Color(0xFF9C27B0),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GERİ BİLDİRİM',
                      style: TextStyle(
                        color: const Color(0xFF9C27B0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Görüşleriniz Bizim İçin Değerli',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeHelper.safeFontSize(context, preferredSize: 28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Topluluğumuzu daha iyi hale getirmek için görüşlerinize ihtiyacımız var. Önerileriniz, şikayetleriniz veya fikirleriniz bizim için çok değerli. Geri bildirimlerinizi paylaşarak topluluğumuzun gelişimine katkıda bulunabilirsiniz.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'info@bmt.edu.tr',
                query: 'subject=Geri Bildirim',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
            icon: const Icon(Icons.send, size: 20),
            label: const Text(
              'Geri Bildirim Gönder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- DESTEK KARTI ---
class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: SizeHelper.safeSize(value: 250, min: 200, max: 300, context: 'Support card width'),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: SizeHelper.safeSize(value: 32, min: 24, max: 40, context: 'Support icon size'),
              ),
            ),
            const SizedBox(height: 16),
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
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
              ),
            ),
          ],
        ),
      ),
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
    List<Widget> children = [
      Expanded(
        flex: 1,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                  fontSize: SizeHelper.safeFontSize(context, preferredSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeHelper.safeFontSize(context, preferredSize: 32),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: SizeHelper.safeFontSize(context, preferredSize: 16),
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 40),
      Expanded(
        flex: 1,
          child: Container(
            height: SizeHelper.safeContainerHeight(context, preferredHeight: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ];

    if (!isImageRight) {
      children = children.reversed.toList();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}